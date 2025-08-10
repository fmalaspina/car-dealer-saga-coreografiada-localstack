package com.example.contracts;
import com.fasterxml.jackson.databind.JsonNode;import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sqs.SqsAsyncClient;import software.amazon.awssdk.services.sqs.model.Message;
@Component @RequiredArgsConstructor
public class SqsPoller {
  private final SqsAsyncClient sqs; private final ObjectMapper om = new ObjectMapper();
  @Value("${app.aws.queueUrl}") String queueUrl;
  @PostConstruct void start(){ poll(); }
  void poll(){
    sqs.receiveMessage(b->b.queueUrl(queueUrl).waitTimeSeconds(20).maxNumberOfMessages(10))
      .thenAccept(resp->{ resp.messages().forEach(this::handle); poll(); });
  }
  void handle(Message m){ try {
      JsonNode outer = om.readTree(m.body());
      String msg = outer.has("Message")? outer.get("Message").asText() : m.body();
      JsonNode body = om.readTree(msg);
      if ("PaymentConfirmed".equals(body.get("type").asText())){
        System.out.println("[contracts] contrato generado para " + body.get("orderId").asText());
      }
    } catch (Exception e) { e.printStackTrace(); }
    finally { sqs.deleteMessage(dm->dm.queueUrl(queueUrl).receiptHandle(m.receiptHandle())); }
  }
}
