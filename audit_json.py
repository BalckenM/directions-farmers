import json, os

base = os.path.join(os.getcwd(), 'assets', 'data', 'mock', 'api', 'poultry')

# daily_records
with open(os.path.join(base, 'daily_records.json')) as f:
    dr = json.load(f)
layer_records = [r for r in dr['data'] if 'eggs_collected_am' in r or 'hdp_pct' in r]
print("daily_records:", len(dr['data']), "total,", len(layer_records), "with layer fields")
if layer_records:
    print("  Sample layer keys:", list(layer_records[0].keys()))
if dr['data']:
    print("  Broiler sample keys:", list(dr['data'][0].keys()))

# vaccination schedules
with open(os.path.join(base, 'vaccination_schedules.json')) as f:
    vs = json.load(f)
if vs['data'] and vs['data'][0].get('schedule'):
    sched_item = vs['data'][0]['schedule'][0]
    print("vaccine schedule item keys:", list(sched_item.keys()))

# inventory
with open(os.path.join(base, 'inventory.json')) as f:
    inv = json.load(f)
if inv['data']:
    print("inventory item keys:", list(inv['data'][0].keys()))

# disease_events
with open(os.path.join(base, 'disease_events.json')) as f:
    de = json.load(f)
if de['data']:
    r = de['data'][0]
    print("disease is_notifiable:", type(r.get('is_notifiable')), r.get('is_notifiable'))
    print("disease reported_to_auth:", type(r.get('reported_to_authorities')), r.get('reported_to_authorities'))
    print("disease keys:", list(r.keys()))

# poultry.json flock list
with open(os.path.join(os.getcwd(), 'assets', 'data', 'mock', 'api', 'livestock', 'poultry.json')) as f:
    flocks = json.load(f)
print("poultry.json:", len(flocks['data']), "flocks")
for flock in flocks['data']:
    ls = flock.get('layer_specific', {})
    if ls:
        print("  layer_specific keys:", list(ls.keys()))
    ds = flock.get('duck_specific', {})
    if ds:
        print("  duck_specific water_access type:", type(ds.get('water_access')), ds.get('water_access'))
    bs = flock.get('broiler_specific', {})
    if bs:
        print("  broiler_specific keys:", list(bs.keys()))

# environment readings
with open(os.path.join(base, 'environment_readings.json')) as f:
    er = json.load(f)
if er['data']:
    print("env_readings keys:", list(er['data'][0].keys()))

# harvest records
with open(os.path.join(base, 'harvest_records.json')) as f:
    hr = json.load(f)
if hr['data']:
    print("harvest_record keys:", list(hr['data'][0].keys()))

# feed phases
with open(os.path.join(base, 'feed_phases.json')) as f:
    fp = json.load(f)
if fp['data']:
    print("feed_phase keys:", list(fp['data'][0].keys()))

# medication logs
with open(os.path.join(base, 'medication_logs.json')) as f:
    ml = json.load(f)
if ml['data']:
    print("medication_log keys:", list(ml['data'][0].keys()))
