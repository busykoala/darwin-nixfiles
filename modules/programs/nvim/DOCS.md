# Neovim Setup Quick Reference

Leader key: `,`

This setup is centered around native Neovim LSP, Snacks, Oil, Trouble, Gitsigns,
Neogit, Diffview, render-markdown, Flash, and Codex.

## Find And Search

| Key | Action |
| --- | --- |
| `,/` | Grep project |
| `,b` | Buffer picker |
| `,ff` | Smart file finder |
| `,fr` | Recent files |
| `,sh` | Help pages |
| `,sk` | Keymaps |
| `,sm` | Marks |

## File Editing

| Key | Action |
| --- | --- |
| `<C-n>` | Open Oil in the current window |

Oil edits directories as buffers, so rename, move, create, and delete files by
editing the listing and writing the buffer.

## Movement

| Key | Action |
| --- | --- |
| `,j` | Flash jump |
| `,J` | Flash Treesitter jump |
| `]r` | Next word reference |
| `[r` | Previous word reference |

Plain Vim `s` and `S` keep their normal substitute behavior.

## Code

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | References |
| `,ca` | Code action |
| `,cf` | Format buffer or selection |
| `,cl` | Run linters |
| `,cr` | Rename symbol |
| `<C-/>` | Toggle comment |

Completion is provided by `blink.cmp`. Formatting uses `conform.nvim`, linting
uses `nvim-lint`, and language intelligence uses native Neovim LSP.

## Diagnostics

| Key | Action |
| --- | --- |
| `,xx` | Toggle Trouble diagnostics |
| `,xX` | Toggle Trouble diagnostics for current buffer |
| `,xs` | Toggle Trouble symbols |
| `,xl` | Toggle Trouble LSP view |

## Git

| Key | Action |
| --- | --- |
| `,gg` | Open Neogit |
| `,gf` | Diff current file with Gitsigns |
| `,gh` | Current file history |
| `,gH` | Repository history |
| `,gv` | Open Diffview |
| `,gV` | Close Diffview |

## Markdown And Notes

Markdown buffers are rendered inline with `render-markdown.nvim`.
Use `,st` to search todo comments and `,uc` to toggle Markdown conceal.

## Terminal And Images

| Key | Action |
| --- | --- |
| `,tt` | Toggle right-side terminal |
| `<Esc><Esc>` | Leave terminal mode |
| `,ih` | Image hover preview |

## Codex

| Key | Action |
| --- | --- |
| `,cc` | Toggle Codex |

Only `,cc` is mapped for Codex. Other Codex features are available as commands:

| Command | Action |
| --- | --- |
| `:Codex` | Toggle the Codex terminal |
| `:CodexSend` | Send visual selection or tree selection |
| `:CodexAdd <path> [start] [end]` | Add a file, directory, or line range |
| `:CodexTreeAdd` | Add selected Oil file entries |

Codex slash commands inside the terminal remain the preferred place for model,
speed, context, and similar chat settings.

## UI Toggles

| Key | Action |
| --- | --- |
| `,us` | Toggle spelling |
| `,uw` | Toggle wrap |
| `,uL` | Toggle relative number |
| `,ud` | Toggle diagnostics |
| `,ui` | Toggle indent guides |
| `,ul` | Toggle line numbers |
| `,uc` | Toggle conceal |
| `,uT` | Toggle Treesitter |
| `,uh` | Toggle inlay hints |
| `,un` | Dismiss notifications |
| `,nh` | Notification history |
