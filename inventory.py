import psycopg2
import sys
import subprocess
import wmi

try:
    connection = psycopg2.connect(user="postgres",
                                  password="i16ae5G3",
                                  host="127.0.0.1",
                                  port="5432",
                                  database="inventory_db")
    cursor = connection.cursor()
    print(connection.get_dsn_parameters(), "\n")
    """cursor.execute("SELECT * FROM public.inventory;")
    record = cursor.fetchall()
    print("Подключились к бд - ", record, "\n")"""
    postgres_table_cr_query = """CREATE TABLE IF NOT EXISTS inventory (
        Name varchar(50),
        Username varchar(50),
        Domain varchar(50),
        Manufacturer varchar(50),
        Model varchar(50),
        CPU varchar(70),
        OS varchar(70),
        SerialNumber varchar(50) PRIMARY KEY,
        Adapter varchar(100),
        Ipadress varchar(50),
        SizeDisk varchar(100),
        Memory varchar(20),
        Macadress varchar(50),
        Display varchar(100)
)"""
    cursor.execute(postgres_table_cr_query)
    connection.commit()
except (Exception, psycopg2.Error) as error:
    print("Ошибка подключения к бд ", error)
else:
    # for table in record:
    # print(table)
    hdd = []
    ram = []
    server = r'.'
    c = wmi.WMI(server)
    gigabyte = 1024*1024*1024

    for sn in c.Win32_Environment():
        if sn.Name == 'SERIALTWO':
            sn2=sn.VariableValue
    print(sn2)

    for sys in c.Win32_ComputerSystem():
        model = sys.Model
        name = sys.Name
        domain = sys.Domain
        manufacturer = sys.Manufacturer
        username = sys.UserName

    for sn in c.Win32_BIOS():
        serialnumber = sn.SerialNumber

    for disk in c.Win32_DiskDrive(MediaType='Fixed hard disk media'):
        hdd.append(disk.Model+"?"+str(round(float(disk.Size)/gigabyte, 2)))
    disk = '*'.join(hdd)

    for rm in c.Win32_PhysicalMemory():
        ram.append(str(round(float(rm.Capacity)/gigabyte)))
        mem = '*'.join(ram)

    postgres_insert_query = """ INSERT INTO public.inventory ("name", "username", "manufacturer", "domain", "model", "serialnumber", "memory") VALUES(%s, %s, %s, %s, %s, %s, %s)"""
    record_to_insert = (name, username, domain,
                        manufacturer, model, mem)
    cursor.execute(postgres_insert_query, record_to_insert)
    connection.commit()
    count = cursor.rowcount
    print(count, "Record inserted successfully into inventory table")
finally:
    if(connection):
        cursor.close()
        connection.close()
        print("Закрыли подключение к бд")
