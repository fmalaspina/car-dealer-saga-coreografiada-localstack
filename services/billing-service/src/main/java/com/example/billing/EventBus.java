package com.example.billing;
import com.fasterxml.jackson.databind.ObjectMapper;import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.sns.SnsClient;import software.amazon.awssdk.services.sns.model.PublishRequest;
@Service @RequiredArgsConstructor
public class EventBus {
  private final SnsClient sns; private final ObjectMapper om = new ObjectMapper();
  @Value("${app.aws.topicArn}") String topicArn;
  public void publish(Object node){
    try { sns.publish(PublishRequest.builder().topicArn(topicArn).message(om.writeValueAsString(node)).build()); }
    catch (Exception e){ throw new RuntimeException(e); }
  }
  public record Event(String type, String orderId) {}
}
