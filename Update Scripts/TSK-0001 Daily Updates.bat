@echo off

SET venv_root_dir="C:\Users\leo.pickard\Desktop\Warehouse db\warehouse_venv"

cd %venv_root_dir%

call %venv_root_dir%\Scripts\activate.bat

cd "C:\Users\leo.pickard\Desktop\warehouse db\Update Scripts\Python"

python "Update dSalesperson Table.py"

python "Update dCountry Table.py"

python "Update dCustomer Table.py"

python "Update fExchange Rates Table.py"

python "Update dItem Table.py"

python "Update dRecord Link.py"

python "Update dInventory Table.py"

python "Update fSales Table.py"

python "Update dGL Accounts.py"

python "Update fGL Entry Table.py"

python "Update dVendor Table.py"

python "Update fPurchases Table.py"

python "Update fLedger Table.py"

python "Update fShipped Qty.py"

python "Update fShipped Qty NAV OG Table.py"

python "Clear Old Data From Database Log.py"

python "Update dWas Item Price Table.py"

python "Update fOrderbook Table.py"

python "Update dImage Table.py"

python "Update dThumbnail Table.py"

python "Rebuild db Indexes.py"

call %venv_root_dir%\Scripts\deactivate.bat

@echo on