#!/usr/bin/bash
read -p "Enter a name for your attendance tracker: " input

if [ -z "$input" ]; then
    echo "Error: No input provided. Please enter a valid name."
    exit 1
fi

PARENT_DIR="attendance_tracker_${input}"

if [ -d "$PARENT_DIR" ]; then
    echo "Error: Directory '$PARENT_DIR' already exists."
    exit 1
fi

mkdir -p "$PARENT_DIR/Helpers"
mkdir -p "$PARENT_DIR/reports"

cat > "$PARENT_DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
# 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat > "$PARENT_DIR/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > "$PARENT_DIR/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

cat > "$PARENT_DIR/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class.
EOF
echo " Directory structure created successfully!"

echo " "
echo "  Attendance Threshold Configuration"
echo " "
echo "  Default Warning threshold : 75%"
echo "  Default Failure threshold : 50%"

read -p "Do you want to update the attendance thresholds? (yes/no): " update_choice
if [[ "$update_choice" == "yes" ]]; then

    while true; do
        read -p "Enter new Warning threshold % (default 75, must be > Failure): " warning_val
        warning_val="${warning_val:-75}"
        if ! [[ "$warning_val" =~ ^[0-9]+$ ]] || [ "$warning_val" -lt 1 ] || [ "$warning_val" -gt 100 ]; then
            echo "  ✘ Invalid input. Please enter a whole number between 1 and 100."
        else
            break
        fi
    done

    while true; do
        read -p "Enter new Failure threshold % (default 50, must be < Warning): " failure_val
        failure_val="${failure_val:-50}"
        if ! [[ "$failure_val" =~ ^[0-9]+$ ]] || [ "$failure_val" -lt 1 ] || [ "$failure_val" -gt 100 ]; then
            echo " Invalid input. Please enter a whole number between 1 and 100."
      
        elif [ "$failure_val" -ge "$warning_val" ]; then
            echo " Failure threshold ($failure_val%) must be less than Warning threshold ($warning_val%)."
        else
            break
        fi
    done
    CONFIG_FILE="$PARENT_DIR/Helpers/config.json"

    sed -i "s/\"warning\": [0-9]*/\"warning\": $warning_val/" "$CONFIG_FILE"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $failure_val/" "$CONFIG_FILE"

    echo " "
    echo " Thresholds updated successfully!"
    echo "  Warning : ${warning_val}%"
    echo "  Failure : ${failure_val}%"
    echo " Updated config.json"
    cat "$CONFIG_FILE"
    echo " "


else
    
    echo " Keeping default thresholds (Warning: 75%, Failure: 50%)."
fi
