import os

features = ['booking', 'catalog', 'gym', 'home', 'membership', 'notification', 'profile']

def setup_feature(feature_name):
    base_path = f"lib/features/{feature_name}"
    
    # Create directories
    dirs = [
        f"{base_path}/data/datasources",
        f"{base_path}/data/models",
        f"{base_path}/data/repositories",
        f"{base_path}/domain/entities",
        f"{base_path}/domain/repositories",
        f"{base_path}/domain/usecases",
        f"{base_path}/presentation/providers",
        f"{base_path}/presentation/screens",
        f"{base_path}/presentation/widgets",
    ]
    
    for d in dirs:
        os.makedirs(d, exist_ok=True)
        
    print(f"Setup directories for {feature_name}")

for feature in features:
    setup_feature(feature)

# Special for explore
setup_feature('explore')
