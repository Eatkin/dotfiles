from selenium import webdriver
from selenium.webdriver.chrome.options import Options

from scraper.common import get_random_user_agent

def create_driver(headless: bool=False) -> webdriver:
	chrome_options = Options()
	chrome_options.add_argument('--headless')
	chrome_options.add_argument('--disable-gpu')
	chrome_options.add_argument('--no-sandbox')
	chrome_options.add_argument(f'user-agent={get_random_user_agent()}')

	driver = webdriver.Chrome(options=chrome_options)
	return driver

