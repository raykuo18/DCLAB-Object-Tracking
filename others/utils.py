import json,codecs
def save_WBundle(dir='./', WBundle = {}):

    filename = dir + f"layer{WBundle['layer']}_g{WBundle['group_index']}_s{WBundle['s']}.json"

    with codecs.open(filename, 'w', encoding='utf-8') as file:
        json.dump(WBundle, file, separators=(',', ':'), sort_keys=True, indent=4) 

def loadWBundle(filename):
    with codecs.open(filename, 'r', encoding='utf-8') as file:
        n = json.loads(file.read())
    return n


def save_IABundle(dir='./IABundles/', IABundles = {}):

    filename = dir + f"layer{IABundles['layer']}.json"

    with codecs.open(filename, 'w', encoding='utf-8') as file:
        json.dump(IABundles, file, separators=(',', ':'), sort_keys=True, indent=4) 

def load_IABundle(filename):
    with codecs.open(filename, 'r', encoding='utf-8') as file:
        n = json.loads(file.read())
    return n