package com.example.dynamo.service;

import com.example.dynamo.dto.ItemDto;
import com.example.dynamo.entities.Item;
import io.awspring.cloud.dynamodb.DynamoDbTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.services.dynamodb.model.ResourceNotFoundException;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
public class ItemService {

    private final DynamoDbTemplate dynamoDbTemplate;

    public ItemService(DynamoDbTemplate dynamoDbTemplate){
        this.dynamoDbTemplate = dynamoDbTemplate;
    }

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    public Item criarItem(ItemDto itemDto) {
        try {
            Item item = new Item();
            LocalDate dataAtual = LocalDate.now();

            item.setNome(itemDto.nome());
            item.setItemId("ITEM#" + UUID.randomUUID().toString());
            item.setData("LIST#" + dataAtual.format(DATE_FORMATTER));
            item.setStatus("Todo");

            dynamoDbTemplate.save(item);
            return item;
        } catch (Exception e) {
            throw new RuntimeException("Erro ao salvar : " + e.getMessage(), e);
        }
    }

    public ResponseEntity<String> deletarItem(String pKey, String sKey) {
        if (pKey == null || sKey == null) {
            return ResponseEntity.badRequest().body("Chave primária ou secundária inválida");
        }

        try {
            Item item = dynamoDbTemplate.load(Key.builder()
                    .partitionValue(pKey)
                    .sortValue(sKey)
                    .build(), Item.class);
            if (item == null) {
                return ResponseEntity.badRequest().body("Item não encontrado.");
            }

            dynamoDbTemplate.delete(item);
            return ResponseEntity.ok().body("Item deletado com sucesso");

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Falha ao deletar o item: " + e.getMessage());
        }
    }
}