#!/bin/sh
systemctl --user daemon-reload
systemctl --user restart pipewire.service
systemctl --user restart wireplumber.service
systemctl --user stop wireplumber.service
