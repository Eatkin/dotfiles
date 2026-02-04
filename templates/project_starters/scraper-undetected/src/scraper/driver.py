import undetected as uc

def create_driver(headless: bool=False) -> uc:
	return uc.Chrome()

