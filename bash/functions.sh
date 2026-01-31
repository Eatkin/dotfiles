__revert_project() {
    local PROJECT_ID="$1"
    local SHOULD_REVERT="$2"

    if [ "$SHOULD_REVERT" -eq 1 ] && [ -n "$PROJECT_ID" ]; then
        gcloud config set project "$PROJECT_ID" >/dev/null
    fi
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

    # Ensure local dir exists if necessary
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

