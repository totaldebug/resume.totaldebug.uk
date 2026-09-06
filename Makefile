.PHONY: install serve build pdf

# Install Ruby gem dependencies.
install:
	bundle install

# Run the local preview server with live reload.
serve:
	bundle exec jekyll serve

# Build the static site into _site/.
build:
	bundle exec jekyll build

# Regenerate Steven-Marks-Resume.pdf from the current content.
pdf:
	./bin/generate-pdf.sh
