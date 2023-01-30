resource "aws_vpc" "this" {
  cidr_block = var.cidr

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = format("${var.name}-public-%s", element(var.azs, count.index))
    },
    var.tags,
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.private_subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format("${var.name}-private-%s", element(var.azs, count.index))
    },
    var.tags,
  )
}

resource "aws_internet_gateway" "this" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-public" },
    var.tags,
  )
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-private" },
    var.tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_eip" "this" {
  count = var.enable_nat_gateway ? length(var.public_subnets) : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "${var.name}-nat-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? length(var.public_subnets) : 0

  allocation_id = element(
    aws_eip.this[*].id,
    count.index
  )
  subnet_id = element(aws_subnet.public[*].id, count.index)

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.public_subnets) : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    count.index
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}
