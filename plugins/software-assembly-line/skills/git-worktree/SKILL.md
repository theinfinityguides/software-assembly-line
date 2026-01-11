# Git Worktree Skill

Manage Git worktrees for isolated parallel development.

## When to Use

- Before starting work on a new feature/story
- When you need to work on multiple branches simultaneously
- To isolate changes from the main working directory

## Worktree Location

Worktrees are created as siblings to the main repo:

```
~/dev/
├── my-repo/              # Main working directory
├── my-repo--feat-auth/   # Worktree for feat/auth branch
└── my-repo--fix-bug/     # Worktree for fix/bug branch
```

Pattern: `<repo-name>--<branch-slug>`

## Commands

### Create Worktree

```bash
# Get repo name and create worktree path
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
BRANCH="feat/STORY-456-add-auth"
BRANCH_SLUG=$(echo "$BRANCH" | sed 's/[^a-zA-Z0-9]/-/g')
WORKTREE_PATH="../${REPO_NAME}--${BRANCH_SLUG}"

# Create branch and worktree
git worktree add -b "$BRANCH" "$WORKTREE_PATH"

# Change to worktree
cd "$WORKTREE_PATH"
```

### List Worktrees

```bash
git worktree list
```

### Switch to Worktree

```bash
cd "../${REPO_NAME}--${BRANCH_SLUG}"
```

### Clean Up Worktree (after PR merged)

```bash
# From main repo
WORKTREE_PATH="../${REPO_NAME}--${BRANCH_SLUG}"

# Remove worktree
git worktree remove "$WORKTREE_PATH"

# Delete branch if merged
git branch -d "$BRANCH"
```

### Prune Stale Worktrees

```bash
git worktree prune
```

## Integration with /work

When `/sal:work` starts:

1. Create worktree for the story branch
2. Change working directory to the worktree
3. Do all work in the worktree
4. Create PR from the worktree
5. After PR merged, clean up worktree

## Session Tracking

The worktree path should be stored in the session file:

```bash
mkdir -p .claude/session
cat > .claude/session/work-goal << EOF
branch=feat/STORY-456-add-auth
worktree=../my-repo--feat-STORY-456-add-auth
EOF
```

## Best Practices

1. **Always work in worktrees** - Keep main directory on main/master
2. **One worktree per story** - Don't mix changes
3. **Clean up after merge** - Remove worktrees when PRs are merged
4. **Use sibling directories** - Easier to navigate than nested `.worktrees/`

## Troubleshooting

### "fatal: is already checked out"

The branch is already checked out somewhere. List worktrees to find it:
```bash
git worktree list
```

### Worktree directory already exists

Remove the stale worktree reference:
```bash
git worktree prune
```

### Can't delete worktree

Make sure you're not currently in that directory:
```bash
cd "$(git rev-parse --show-toplevel)"  # Go to main repo
git worktree remove "$WORKTREE_PATH"
```
