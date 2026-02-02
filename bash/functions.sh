__revert_project() {
    local PROJECT_ID="$1"
    local SHOULD_REVERT="$2"

    if [ "$SHOULD_REVERT" -eq 1 ] && [ -n "$PROJECT_ID" ]; then
        gcloud config set project "$PROJECT_ID" >/dev/null
    fi
}

__file_nonempty() {
    [ -f "$1" ] && [ -s "$1" ]
}

sync_data() {
    local MODE="$1"   # push | pull
    local LOCAL_DIR="$HOME/.data-sources"
    local BUCKET_URI="gs://data-sync-bucket-1234"
    local PROJECT_ID="hazel-tea-432510-g6"

    command -v gcloud >/dev/null 2>&1 || {
        echo "gcloud not installed"
        return 1
    }

    # Auth check
    if [ "$(gcloud auth list --filter=status:ACTIVE --format='value(account)')" = "" ]; then
        echo "No gcloud authentication, run: gcloud auth login"
        return 1
    fi

    # Project handling
    local CURRENT_PROJECT
    CURRENT_PROJECT="$(gcloud config get project --format='value(core.project)')"

    local REVERT_PROJECT=0
    if [ "$CURRENT_PROJECT" != "$PROJECT_ID" ]; then
        REVERT_PROJECT=1
        gcloud config set project "$PROJECT_ID"
    fi

     #Ensure local dir exists if necessary
    if [ "$MODE" = "pull" ]; then
        mkdir -p "$LOCAL_DIR" || {
            echo "Failed to create $LOCAL_DIR"
            __revert_project "$CURRENT_PROJECT" "$REVERT_PROJECT"
            return 1
        }
    fi

    [ -d "$LOCAL_DIR" ] || {
        echo "Local data directory missing: $LOCAL_DIR"
        __revert_project "$CURRENT_PROJECT" "$REVERT_PROJECT"
        return 1
    }

    # If we have newsboat sync the urls file
    # This is a special case cause newsboat lives in its own directory and is not managed by me
    if command -v newsboat >/dev/null 2>&1; then
        DATA_SOURCE="$LOCAL_DIR/rss"
        SNAP_DEST="$HOME/snap/newsboat/current/.newsboat/"

        # Make sure they exist
        mkdir -p "$DATA_SOURCE"
        mkdir -p "$SNAP_DEST"

        DATA_FILE="$DATA_SOURCE/urls"
        NEWSBOAT_FILE="$SNAP_DEST/urls"
        
        # This uses a smart sync so the newest file is always kept
        # Avoids overwriting with blank files
        if __file_nonempty "$DATA_FILE" && __file_nonempty "$NEWSBOAT_FILE"; then
            # Both exist and have content: newer wins
            if [ "$DATA_FILE" -nt "$NEWSBOAT_FILE" ]; then
                rsync -au "$DATA_FILE" "$NEWSBOAT_FILE"
            else
                rsync -au "$NEWSBOAT_FILE" "$DATA_FILE"
            fi
        elif __file_nonempty "$DATA_FILE"; then
            # Only canonical exists: copy to Newsboat
            rsync -au "$DATA_FILE" "$NEWSBOAT_FILE"
        elif __file_nonempty "$NEWSBOAT_FILE"; then
            # Only Newsboat exists: copy to canonical
            rsync -au "$NEWSBOAT_FILE" "$DATA_FILE"
        else
            # Neither exists or both empty: do nothing
            echo "Warning: no RSS URLs found in either location, nothing synced."
        fi
    fi


    case "$MODE" in
        push)
            gcloud storage rsync --recursive --checksums-only \
                "$LOCAL_DIR" "$BUCKET_URI"
            ;;
        pull)
            gcloud storage rsync --recursive --checksums-only \
                "$BUCKET_URI" "$LOCAL_DIR"
            ;;
        *)
            echo "Usage: sync_data {push|pull}"
            __revert_project "$CURRENT_PROJECT" "$REVERT_PROJECT"
            return 1
            ;;
    esac

    __revert_project "$CURRENT_PROJECT" "$REVERT_PROJECT"

}

