.PHONY: help
## help          : Display this help message with available targets.
help: Makefile
	@sed -n 's/^##//p' $<

.PHONY: check-command
## check-command : Check if a given command is installed, if not, install it.
check-command:
	@which $(cmd) > /dev/null 2>&1 || { \
		echo "$(cmd) not found, installing it..."; \
		$(installer); \
	}
	@echo "$(cmd) is installed"

.PHONY: check-hugo
## check-hugo    : Check if Hugo is installed, and if not, install it (MacOS).
check-hugo: check-command
	$(MAKE) check-command cmd=hugo installer="brew install hugo"


.PHONY: new-blog
## new-blog      : Generate a new blog file with the given name using Hugo.
new-blog:
	hugo new content/posts/$(name).md

.PHONY: live
live:
	hugo server --disableFastRender