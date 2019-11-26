# PowerFunctions

This is a collection of functions I have created to use with Powershell v5, and should work with any Windows 10 or newer PC 'out of the box'.

Functions will be added over time, so keep checking in!

### INIFunctions

INIFunctions creates an Import-Ini function and an Export-Ini function to allow you to read an INI file into a powershell script, and then manipulate and eventually re-export the INI from powershell.

The PSObject will be arranged by $Variable.Header.Option, so an example object would be:

* $Variable.Settings.Value1
* $Variable.Settings.Value2
* $Variable.Recent.File1
* $Variable.Network.IP

Ecetera.
