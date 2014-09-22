#!/bin/bash

# Copy all the public directory via SSH
scp -r public/*    53ea1c4e500446e37600008e@beta-squareteam.rhcloud.com:~/app-root/runtime/repo/public/
