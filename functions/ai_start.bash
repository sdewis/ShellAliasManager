ai_start() {
    local p_name=$(basename "$(pwd)")
    cat << PROMPT > AI_SESSION.md
# SYSTEM ROLE: Elite Architect
# CONTEXT: Working in $(pwd)

# LOCAL TODOs (Handed off to AI)
$( [[ -f .todo ]] && cat .todo || echo "No manual tasks." )

# PROJECT STRUCTURE
$(ls -F | head -n 15)

# INSTRUCTIONS:
Analyze the TODOs and current files. Propose a plan for the next step.
PROMPT
    echo -e "${PURPLE}✔ AI_SESSION.md created with local context.${RESET}"
}
