f=open('links.txt','r')
s=f.read()
f.close()
s=s.replace('</code>','')
s=s.replace('</code','')
s=s.replace('</div>','')
s=s.replace('</div','')
f=open('links.txt','w')
f.write(s)
f.close()