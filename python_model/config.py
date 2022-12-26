import yaml
from yaml.loader import SafeLoader

class Config():
    def __init__(self) -> None:
        pass
    
    def __call__(self, module: str) -> dict:
        # Open the file and load the file
        with open('config.yaml') as f:
            data = yaml.load(f, Loader=SafeLoader)
            
        module_ = module.split('/')
        try:
            for m in module_:
                data = data[m]
            return data
        except:
            print(f"Config '{module}' not found")
            return {}

if __name__ == '__main__':
    # Example
    print(Config()('PE'))
    print(Config()('PE/AIM'))
    print(Config()('PE/OA_Addr'))