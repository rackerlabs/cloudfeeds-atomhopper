# AWS For Fluent Bit
In this directory we have placed all the custom config files required for AWS Fluent Bit image for log collection of Cloudfeeds Atomhopper, Repose Internal, Repose External and Catalog.

This directory contains a [Dockerfile](./Dockerfile.aws-fluent-bit) which will create a custom container image for aws-for-fluent-bit with the custom configuration files copied inside this new image.

If possible before running the EC2 image builder pipeline for FluentBit fetch the latest container image for `aws-for-fluent-bit` from public ECR repository and set it in the [Dockerfile](./Dockerfile.aws-fluent-bit).

We have also enabled health check of this fluent-bit custom image so that ECS can perform health check.

### Reference links
- [https://github.com/aws/aws-for-fluent-bit/blob/develop/use_cases/init-process-for-fluent-bit/](https://github.com/aws/aws-for-fluent-bit/blob/develop/use_cases/init-process-for-fluent-bit/)

- [https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/cloudwatchlogs](https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/cloudwatchlogs)

- [https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/health-check](https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/health-check)

- [https://docs.fluentbit.io/manual/administration/monitoring#health-check-for-fluent-bit](https://docs.fluentbit.io/manual/administration/monitoring#health-check-for-fluent-bit)

- [https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/ecs-log-collection](https://github.com/aws-samples/amazon-ecs-firelens-examples/tree/mainline/examples/fluent-bit/ecs-log-collection)
