return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },

    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      local dap_python = require "dap-python"

      dap_python.setup("python3")

      dap_python.test_runner = "pytest"

      dapui.setup {
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks", size = 0.20 },
              { id = "watches", size = 0.20 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
      }

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      require("nvim-dap-virtual-text").setup {
        commented = true,
      }

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapLogPoint", { text = "◎", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
      end

      -- Core
      map("<F5>", dap.continue, "DAP: Continue / Start")
      map("<Down>", dap.step_over, "DAP: Step Over")
      map("<Right>", dap.step_into, "DAP: Step Into")
      map("<Left>", dap.step_out, "DAP: Step Out")
      map("<leader>db", dap.toggle_breakpoint, "DAP: Toggle Breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input "Condition: ")
      end, "DAP: Conditional Breakpoint")
      map("<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input "Log message: ")
      end, "DAP: Log Point")
      map("<leader>dr", dap.repl.open, "DAP: Open REPL")
      map("<leader>dq", dap.terminate, "DAP: Terminate")

      -- UI toggle
      map("<leader>du", dapui.toggle, "DAP: Toggle UI")

      -- Python-specific
      map("<leader>dm", dap_python.test_method, "DAP: Debug Test Method")
      map("<leader>dc", dap_python.test_class, "DAP: Debug Test Class")
    end,
  },
}
