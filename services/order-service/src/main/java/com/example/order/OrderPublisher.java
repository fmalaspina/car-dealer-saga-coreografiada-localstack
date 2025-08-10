package com.example.order;
import com.fasterxml.jackson.databind.ObjectMapper;import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;import org.springframework.boot.CommandLineRunner;import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sns.SnsClient;import software.amazon.awssdk.services.sns.model.PublishRequest;
@Component @RequiredArgsConstructor
public class OrderPublisher implements CommandLineRunner {
  private final SnsClient sns;
  private final ObjectMapper om = new ObjectMapper();
  @Value("${app.aws.topicArn}") String topicArn;
  @Override public void run(String... args) throws Exception {
    var payload = """
    {"type":"OrderPlaced","orderId":"O-2001","model":"Sedan-X"}
    """;
    sns.publish(PublishRequest.builder().topicArn(topicArn).message(payload).build());
    System.out.println("[order] published OrderPlaced");
  }
}
