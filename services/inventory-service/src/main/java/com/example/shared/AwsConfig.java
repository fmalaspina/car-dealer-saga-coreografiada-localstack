package com.example.shared;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sqs.SqsAsyncClient;
import java.net.URI;

@Configuration
public class AwsConfig {
  @Value("${app.aws.region}")   String region;
  @Value("${app.aws.endpoint}") String endpoint;
  @Value("${AWS_ACCESS_KEY_ID}") String accessKey;
  @Value("${AWS_SECRET_ACCESS_KEY}") String secretKey;

  @Bean
  public SqsAsyncClient sqs() {
    return SqsAsyncClient.builder()
      .region(Region.of(region))
      .endpointOverride(URI.create(endpoint))
      .credentialsProvider(StaticCredentialsProvider.create(
        AwsBasicCredentials.create(accessKey, secretKey)))
      .build();
  }

  @Bean
  public SnsClient sns() {
    return SnsClient.builder()
      .region(Region.of(region))
      .endpointOverride(URI.create(endpoint))
      .credentialsProvider(StaticCredentialsProvider.create(
        AwsBasicCredentials.create(accessKey, secretKey)))
      .build();
  }
}
