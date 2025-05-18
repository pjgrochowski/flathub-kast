MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
DIR_MAKEFILE := $(dir $(MAKEFILE_PATH))

APPLICATION_ID := io.bitbucket.Kast
APPLICATION_MANIFEST := $(DIR_MAKEFILE)/$(APPLICATION_ID).yml
APPLICATION_METAINFO := $(DIR_MAKEFILE)/$(APPLICATION_ID).metainfo.xml

DIR_STATE := $(DIR_MAKEFILE)/.flatpak-builder
DIR_BUILD := $(DIR_MAKEFILE)/builddir
DIR_REPO := $(DIR_MAKEFILE)/repo

CMD_FLATPAK_RUN := flatpak run --state-dir=$(DIR_STATE)

define func_build
	$(eval $@_IS_SANDBOXED = $(1))
	$(eval $@_SANDBOX_PARAM = $(intcmp $($@_IS_SANDBOXED), 0, , , --sandbox))

	flatpak run org.flatpak.Builder \
		--force-clean \
		$($@_SANDBOX_PARAM) \
		--user \
		--install \
		--install-deps-from=flathub \
		--ccache \
		--mirror-screenshots-url=https://dl.flathub.org/media/ \
		--state-dir=$(DIR_STATE) \
		--repo=$(DIR_REPO) \
		$(DIR_BUILD) \
		$(APPLICATION_MANIFEST)
endef

# That needs to run only once:
setup:
	flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
	flatpak install -y flathub org.flatpak.Builder

clean:
	rm -rfv $(DIR_STATE)/ $(DIR_BUILD)/ $(DIR_REPO)/

uninstall:
	flatpak uninstall $(APPLICATION_ID)

release:
	$(call func_build, 1)

develop:
	$(call func_build, 0)

validate: validate-manifest validate-metainfo validate-repo

validate-manifest:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest $(APPLICATION_MANIFEST)

validate-metainfo:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder appstream $(APPLICATION_METAINFO)

validate-repo:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo $(DIR_REPO)

run:
	flatpak run $(APPLICATION_ID) -d
