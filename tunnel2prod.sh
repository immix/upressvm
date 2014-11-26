#!/bin/bash
nc -z localhost 3305 || sshpass -p 'bada55' ssh -f 10.0.1.106 -L 3305:127.0.0.1:3306 -N