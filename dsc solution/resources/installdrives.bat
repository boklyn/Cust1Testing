cmdkey /add:dsuswgisfilsa.file.core.windows.net /user:dsuswgisfilsa /pass:Au4FX8BlPnCCqrqD26q+37uLRP6PMl776ZfldoadxNUUzdvRpLBvxhUUc6omrWtWOFEfz8oI6Cr7WX+oBdFlkg==
cmdkey /add:dsuswsysfilsa.file.core.windows.net /user:dsuswsysfilsa /pass:60yiRSJYywfd9krllF3S/92gQLkJsgpNwUEKOxabAUJ1Z157bOuhe/vdBmAFkw8RzpeL1JadB9RdJnFymB5kzQ==
cmdkey /add:dsuswpubfilsa.file.core.windows.net /user:dsuswpubfilsa /pass:pQD4mYgZZ3Il6S5AnKnWe28AbdL1eH7pikZQPihQJbE8SzA1HctKo1p+YIOtqdrMimHGI/8LqiQZGXbPHSYQmg==
cmdkey /add:dsusworafilsa.file.core.windows.net /user:dsusworafilsa /pass:GkfKR+zIoY3I5V1CVHD4fS7gLwg/RxdfH7jbe6wtIuUu5jPg/KBtPMqOVLUNeL0uIMFqXditKFwmaA2gxn499Q==
cmdkey /add:dsuswhstfilsa.file.core.windows.net /user:dsuswhstfilsa /pass:lNFZ9LvcVxl/2aGJm5vTwsJWQlPCK3umZdA3jf73EFEFPKJwolq8Ez6S6mirs550aZeelHiqOVQIzzCzD1hglQ==
net use G: \\dsuswgisfilsa.file.core.windows.net\gis /persistent:yes
net use S: \\dsuswsysfilsa.file.core.windows.net\sys /persistent:yes
net use P: \\dsuswpubfilsa.file.core.windows.net\pub /persistent:yes
net use I: \\usw-fsprd1-vm\Data /persistent:yes
net use J: \\dsuswhstfilsa.file.core.windows.net\hst /persistent:yes
net use O: \\dsusworafilsa.file.core.windows.net\ora /persistent:yes