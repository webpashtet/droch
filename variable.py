import os
import sys
from subprocess import check_call
if sys.hexversion > 0x03000000:
    import winreg
else:
    import _winreg as winreg


class Win32Environment:

    def __init__(self, scope):
        assert scope in ('user', 'system')
        self.scope = scope
        if scope == 'user':
            self.root = winreg.HKEY_CURRENT_USER
            self.subkey = 'Environment'
        else:
            self.root = winreg.HKEY_LOCAL_MACHINE
            self.subkey = r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'

    def getenv(self, name):
        key = winreg.OpenKey(self.root, self.subkey, 0, winreg.KEY_READ)
        try:
            value, _ = winreg.QueryValueEx(key, name)
        except WindowsError:
            value = ''
        return value

    def setenv(self, name, value):
        # для 'system' scope запускать с админскими правами
        key = winreg.OpenKey(self.root, self.subkey, 0, winreg.KEY_ALL_ACCESS)
        winreg.SetValueEx(key, name, 0, winreg.REG_EXPAND_SZ, value)
        winreg.CloseKey(key)
        check_call('''\
"%s" -c "import win32api, win32con; assert win32api.SendMessage(win32con.HWND_BROADCAST, win32con.WM_SETTINGCHANGE, 0, 'Environment')"''' % sys.executable)


# scope="system" у меня с админскими правами не захотел работать
e2 = Win32Environment(scope="system")
e2.setenv('SERIALTWO', 'TEST_SERIAL_NUMBER')
print(e2.getenv('SERIALTWO'))

# как получить?

'''server = r'.'
    c = wmi.WMI(server)

for sn in c.Win32_Environment():
        if sn.Name == 'SERIALTWO':
            sn2 = sn.VariableValue
    print(sn2)
'''