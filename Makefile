.PHONY: help setup

all: help

help:
	cat Makefile

setup:
	bundle install
	brew install ngrok
