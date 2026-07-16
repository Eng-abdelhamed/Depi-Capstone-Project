resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id 
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "${var.environment}-nat" }
}