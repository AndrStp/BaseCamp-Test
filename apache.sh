#! /bin/bash

# install & run apache
sudo yum install httpd

sudo systemctl start httpd
sudo systemctl enable httpd

# change default web page
cat > /var/www/html/index.html << 'EOF'
<html>\n
<head>\n
</head>\n
<body>Andriy Stepanenko\n</body>\n
</html>
EOF

