# Lesson 7 — VPC endpoint policies as the "network perimeter": the third leg of the data
# perimeter triad alongside the SCP #8 identity perimeter and RCP #1 resource perimeter.
# A VPC endpoint policy restricts what a specific network path (this endpoint) can be used
# for — so even if compute inside this VPC is compromised, traffic leaving through this
# endpoint can only be used by our own org's identities to reach our own org's resources.

# Minimal VPC just to host the endpoint — not a general-purpose networking lesson.
resource "aws_vpc" "network_perimeter_test" {
  provider   = aws.sandbox_network
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "network-perimeter-test-vpc"
  }
}

# Gateway endpoints attach to route tables (not subnets/ENIs like Interface endpoints do).
# Every VPC gets an auto-created main route table — reuse it rather than creating another.
data "aws_route_table" "network_perimeter_test_main" {
  provider = aws.sandbox_network
  vpc_id   = aws_vpc.network_perimeter_test.id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  provider          = aws.sandbox_network
  vpc_id            = aws_vpc.network_perimeter_test.id
  service_name      = "com.amazonaws.${local.network_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.network_perimeter_test_main.id]

  # Replaces the default wide-open ("Principal *, Action *, Resource *") endpoint policy.
  # Once you attach a custom policy, only requests matching an Allow statement pass through
  # this endpoint — same implicit-deny evaluation model as an identity policy or permission
  # boundary, just enforced at the network layer instead.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RestrictToOrgIdentitiesAndResources"
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = aws_organizations_organization.this.id
            "aws:ResourceOrgID"  = aws_organizations_organization.this.id
          }
        }
      },
    ]
  })

  tags = {
    Name = "network-perimeter-test-s3-endpoint"
  }
}
