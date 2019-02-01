Overview

The generateSnowflakeRSAKeys.ps1 is a simple utility script to generate RSA keys suiable for use as authenication credentials with Snowflake Computing services (a SaaS data warehouse) and possibly more. It uses the Chilkat library for the mathy bits and formatting. So while the script is offered under the MIT license, production use will require a license of Chilkat, which one can obtain here: https://www.chilkatsoft.com/

Usage

To use the script, you must first download and configure the Chilkat library. Once it's in place, you'll need to edit the script to indicate the location of the library in the $CHILKATDLLFILE variable. 

You may also want to set the $PRIVATEKEYFILEDIR and $PUBLICKEYFILEDIR values to a directory other than C:\Windows\Temp\. If you don't, all keys created will be placed in that directory. 

At runtime, you will be asked for a user name and passphrase for the key. The user name will be used in the naming of the key files. The keys will be named according to this naming convention: UserNameForKey-timestamp-(private|public)Key.pem. If you were to say the user name was "Daredevil" when the script runs, the resulting private key may be named "Daredevil-2019-02-01T18.41.41.6410943+00.00-privateKey.pem" and will be saved in C:\Windows\Temp\. 
