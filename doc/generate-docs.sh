#!/bin/sh

rm -rf valadoc
valadoc \
	-o valadoc \
	--basedir=.. \
	--package-name=couchbase \
	--package-version=0.1 \
	--deps \
	--vapidir=../vapi \
	--doclet=html \
	--driver=0.24.x \
	--pkg=glib-2.0 \
	--pkg=gmodule-2.0 \
	--pkg=gee-0.8 \
	--pkg=json-glib-1.0 \
	--pkg=libcouchbase \
	`find ../src -name \*.vala -print` \
	--force
