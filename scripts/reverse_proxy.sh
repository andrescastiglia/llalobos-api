#!/bin/bash
#sudo ufw allow 5432/tcp
ssh -L 0.0.0.0:5432:localhost:5432 lla
