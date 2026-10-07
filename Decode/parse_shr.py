import csv
import sys
import os

# Lookup dictionaries
MAPPINGS = {
    "Numeric State Code": {
        "50": "AK-Alaska", "01": "AL-Alabama", "03": "AR-Arkansas", "54": "AS-American Samoa", 
        "02": "AZ-Arizona", "04": "CA-California", "05": "CO-Colorado", "06": "CT-Connecticut", 
        "52": "CZ-Canal Zone", "08": "DC-District of Columbia", "07": "DE-Delaware", "09": "FL-Florida", 
        "10": "GA-Georgia", "55": "GM-Guam", "51": "HI-Hawaii", "14": "IA-Iowa", "11": "ID-Idaho", 
        "12": "IL-Illinois", "13": "IN-Indiana", "15": "KS-Kansas", "16": "KY-Kentucky", 
        "17": "LA-Louisiana", "20": "MA-Massachusetts", "19": "MD-Maryland", "18": "ME-Maine", 
        "21": "MI-Michigan", "22": "MN-Minnesota", "24": "MO-Missouri", "23": "MS-Mississippi", 
        "25": "MT-Montana", "26": "NB-Nebraska", "32": "NC-North Carolina", "33": "ND-North Dakota", 
        "28": "NH-New Hampshire", "29": "NJ-New Jersey", "30": "NM-New Mexico", "27": "NV-Nevada", 
        "31": "NY-New York", "34": "OH-Ohio", "35": "OK-Oklahoma", "36": "OR-Oregon", 
        "37": "PA-Pennsylvania", "53": "PR-Puerto Rico", "38": "RI-Rhode Island", "39": "SC-South Carolina", 
        "40": "SD-South Dakota", "41": "TN-Tennessee", "42": "TX-Texas", "43": "UT-Utah", 
        "62": "VI-Virgin Islands", "45": "VA-Virginia", "44": "VT-Vermont", "46": "WA-Washington", 
        "48": "WI-Wisconsin", "47": "WV-West Virginia", "49": "WY-Wyoming"
    },
    "Group": {
        "0": "Possessions", "1": "All cities 250,000 or over", "1A": "Cities 1,000,000 or over", 
        "1B": "Cities from 500,000 thru 999,999", "1C": "Cities from 250,000 thru 499,999", 
        "2": "Cities from 100,000 thru 249,999", "3": "Cities from 50,000 thru 99,999", 
        "4": "Cities from 25,000 thru 49,999", "5": "Cities from 10,000 thru 24,999", 
        "6": "Cities from 2,500 thru 9,999", "7": "Cities under 2,500", "8": "Non-MSA Counties", 
        "8A": "Non-MSA counties 100,000 or over", "8B": "Non-MSA counties from 25,000 thru 99,999", 
        "8C": "Non-MSA counties from 10,000 thru 24,999", "8D": "Non-MSA counties under 10,000", 
        "8E": "Non-MSA State Police", "9": "MSA Counties", "9A": "MSA counties 100,000 or over", 
        "9B": "MSA counties from 25,000 thru 99,999", "9C": "MSA counties from 10,000 thru 24,999", 
        "9D": "MSA counties under 10,000", "9E": "MSA State Police"
    },
    "Division": {
        "0": "Possessions", "1": "New England", "2": "Middle Atlantic", "3": "East North Central", 
        "4": "West North Central", "5": "South Atlantic", "6": "East South Central", 
        "7": "West South Central", "8": "Mountain", "9": "Pacific"
    },
    "MSA Indication": {
        "0": "Non-Suburban", "1": "Suburban"
    },
    "Action Type": {
        "0": "Normal update", "1": "Adjustment"
    },
    "Homicide": {
        "A": "Murder and Nonnegligent Manslaughter", "B": "Manslaughter by Negligence"
    },
    "Situation": {
        "A": "Single Victim/Single Offender", "B": "Single Victim/Unknown Offender(s)", 
        "C": "Single Victim/Multiple Offenders", "D": "Multiple Victims/Single Offender", 
        "E": "Multiple Victims/Multiple Offenders", "F": "Multiple Victims/Unknown Offender(s)"
    },
    "Sex": {
        "M": "Male", "F": "Female", "U": "Unknown"
    },
    "Race": {
        "W": "White", "B": "Black", "I": "American Indian or Alaskan Native", 
        "A": "Asian or Pacific Islander", "U": "Unknown"
    },
    "Ethnic": {
        "H": "Hispanic Origin", "N": "Not of Hispanic Origin", "U": "Unknown"
    },
    "Weapon": {
        "11": "Firearm, type not stated", "12": "Handgun", "13": "Rifle", "14": "Shotgun", 
        "15": "Other Gun", "20": "Knife/Cutting Instrument", "30": "Blunt Object", 
        "40": "Personal Weapons", "50": "Poison", "55": "Pushed or thrown out window", 
        "60": "Explosives", "65": "Fire", "70": "Narcotics/Drugs", "75": "Drowning", 
        "80": "Strangulation - hanging", "85": "Asphyxiation", "90": "Other"
    },
    "Relationship": {
        "HU": "Husband", "WI": "Wife", "CH": "Common-Law Husband", "CW": "Common-Law Wife", 
        "MO": "Mother", "FA": "Father", "SO": "Son", "DA": "Daughter", "BR": "Brother", 
        "SI": "Sister", "IL": "In-Law", "SF": "Stepfather", "SM": "Stepmother", "SS": "Stepson", 
        "SD": "Stepdaughter", "OF": "Other Family", "NE": "Neighbor", "AQ": "Acquaintance", 
        "BF": "Boyfriend", "GF": "Girlfriend", "XH": "Ex-Husband", "XW": "Ex-Wife", 
        "EE": "Employee", "ER": "Employer", "FR": "Friend", "HO": "Homosexual Relationship", 
        "OK": "Other - known to victim", "ST": "Stranger", "UN": "Unknown Relationship"
    },
    "Circumstance": {
        "02": "Rape", "03": "Robbery", "05": "Burglary", "06": "Larceny", "07": "Motor Vehicle Theft", 
        "09": "Arson", "10": "Prostitution and Commercialized Vice", "17": "Other Sex Offenses", 
        "32": "Abortion", "18": "Narcotic Drug Laws", "19": "Gambling", "26": "Other - not specified", 
        "40": "Lover's Triangle", "41": "Child Killed by Babysitter", "42": "Brawl Due to Influence of Alcohol", 
        "43": "Brawl Due to Influence of Narcotics", "44": "Argument Over Money or Property", 
        "45": "Other Arguments", "46": "Gangland Killings", "47": "Juvenile Gang Killings", 
        "48": "Institutional Killings", "49": "Sniper Attack", "60": "Other", "70": "All Suspected Felony Type", 
        "80": "Felon Killed by Private Citizen", "81": "Felon Killed by Police", 
        "99": "Unable to Determine", "50": "Victim Shot in Hunting Accident", "51": "Gun-Cleaning Death", 
        "52": "Children Playing With Gun", "53": "Other Negligent Handling of Gun", 
        "59": "All Other Manslaughter by Negligence"
    },
    "Sub-Circumstance": {
        "A": "Felon Attacked Police Officer", "B": "Felon Attacked Fellow Police Officer", 
        "C": "Felon Attacked a Civilian", "D": "Felon Attempted Flight From a Crime", 
        "E": "Felon Killed in Commission of a Crime", "F": "Felon Resisted Arrest", 
        "G": "Not Enough Information to Determine"
    }
}

def decode_age(age_val):
    if not age_val.strip():
        return ""
    if age_val == "NB": return "Birth-6 days"
    if age_val == "BB": return "7 days to 364 days"
    if age_val == "00": return "Unknown"
    if age_val == "99": return "99 years or older"
    return age_val

def parse_shr(input_file, output_file):
    # Field definitions: (Name, Length, LookupDictName)
    fields = [
        ("Identifier Code", 1, None),
        ("Numeric State Code", 2, "Numeric State Code"),
        ("ORI Code", 7, None),
        ("Group", 2, "Group"),
        ("Division", 1, "Division"),
        ("Year", 2, None),
        ("Population", 9, None),
        ("County", 3, None),
        ("MSA", 3, None),
        ("MSA Indication", 1, "MSA Indication"),
        ("Agency Name", 24, None),
        ("State Name", 6, None),
        ("Offense Month", 2, None),
        ("Last Update", 6, None),
        ("Action Type", 1, "Action Type"),
        ("Homicide", 1, "Homicide"),
        ("Incident Number", 3, None),
        ("Situation", 1, "Situation"),
    ]

    # Victim 1
    fields.extend([
        ("Vic 1 Age", 2, "Age"),
        ("Vic 1 Sex", 1, "Sex"),
        ("Vic 1 Race", 1, "Race"),
        ("Vic 1 Ethnic", 1, "Ethnic"),
    ])

    # Offender 1
    fields.extend([
        ("Off 1 Age", 2, "Age"),
        ("Off 1 Sex", 1, "Sex"),
        ("Off 1 Race", 1, "Race"),
        ("Off 1 Ethnic", 1, "Ethnic"),
        ("Off 1 Weapon", 2, "Weapon"),
        ("Off 1 Relationship", 2, "Relationship"),
        ("Off 1 Circumstance", 2, "Circumstance"),
        ("Off 1 Sub-Circumstance", 1, "Sub-Circumstance"),
    ])

    fields.extend([
        ("Victim Count", 3, None),
        ("Offender Count", 3, None),
    ])

    # Victims 2 to 11
    for i in range(2, 12):
        fields.extend([
            (f"Vic {i} Age", 2, "Age"),
            (f"Vic {i} Sex", 1, "Sex"),
            (f"Vic {i} Race", 1, "Race"),
            (f"Vic {i} Ethnic", 1, "Ethnic"),
        ])

    # Offenders 2 to 11
    for i in range(2, 12):
        fields.extend([
            (f"Off {i} Age", 2, "Age"),
            (f"Off {i} Sex", 1, "Sex"),
            (f"Off {i} Race", 1, "Race"),
            (f"Off {i} Ethnic", 1, "Ethnic"),
            (f"Off {i} Weapon", 2, "Weapon"),
            (f"Off {i} Relationship", 2, "Relationship"),
            (f"Off {i} Circumstance", 2, "Circumstance"),
            (f"Off {i} Sub-Circumstance", 1, "Sub-Circumstance"),
        ])

    field_names = [f[0] for f in fields]

    with open(input_file, 'r', encoding='utf-8', errors='replace') as infile, \
         open(output_file, 'w', newline='', encoding='utf-8') as outfile:
        
        writer = csv.DictWriter(outfile, fieldnames=field_names)
        writer.writeheader()
        
        for line_num, line in enumerate(infile, 1):
            line = line.strip('\r\n')
            if not line:
                continue
                
            # Pad line to 268 chars if it's shorter due to trailing spaces being stripped
            line = line.ljust(268)
            
            row = {}
            current_pos = 0
            for field_name, field_len, lookup_type in fields:
                val = line[current_pos:current_pos+field_len].strip()
                
                if val:
                    if lookup_type == "Age":
                        val = decode_age(val)
                    elif lookup_type and lookup_type in MAPPINGS:
                        # Map the value if it exists in the dictionary, otherwise keep original
                        val = MAPPINGS[lookup_type].get(val, val)
                
                row[field_name] = val
                current_pos += field_len
                
            writer.writerow(row)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python parse_shr.py <input_txt> <output_csv>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)
        
    print(f"Parsing '{input_file}' to '{output_file}'...")
    parse_shr(input_file, output_file)
    print(f"Successfully parsed {input_file} to {output_file}")
