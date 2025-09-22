# DirHealthMonitor

**DirHealthMonitor** is a lightweight Bash script that monitors directories on Linux systems for disk and inode usage, generates daily logs, sends alerts, and cleans old log files.

## Features
- Monitor multiple directories
- Check disk and inode usage
- Send desktop notifications
- Automatic cleanup of old logs
- Daily log rotation

## Installation
Clone repo, make script executable (chmod +x dirMON.sh), create log folder.

## Viewing Logs
```bash
tail -n 20 /home/amal/forpro/logs/dirhealth.log

cat /home/amal/forpro/logs/dirhealth_2025-09-22.log
```

## Usage
Run manually: ./dirMON.sh  
Schedule via cron for automatic daily monitoring:  
```bash
crontab -e

```

## License
MIT License

## Author
Amal Krishna
