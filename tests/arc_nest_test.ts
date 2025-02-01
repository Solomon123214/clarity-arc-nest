import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure user can create a new project",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('arc-nest', 'create-project', [
        types.ascii("My Novel")
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1));
    
    // Verify project details
    let projectBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'get-project', [
        types.uint(1)
      ], deployer.address)
    ]);
    
    const project = projectBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(project.owner, deployer.address);
    assertEquals(project.title, "My Novel");
  }
});

Clarinet.test({
  name: "Test character creation and retrieval",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // First create a project
    let projectBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'create-project', [
        types.ascii("My Novel")
      ], deployer.address)
    ]);
    
    // Add a character to the project
    let characterBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'add-character', [
        types.uint(1),
        types.ascii("John Doe"),
        types.utf8("A mysterious character")
      ], deployer.address),
      // Unauthorized attempt
      Tx.contractCall('arc-nest', 'add-character', [
        types.uint(1),
        types.ascii("Jane Doe"),
        types.utf8("Another character")
      ], wallet1.address)
    ]);
    
    characterBlock.receipts[0].result.expectOk();
    characterBlock.receipts[1].result.expectErr(types.uint(102)); // err-unauthorized
    
    // Verify character details
    let getCharacterBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'get-character', [
        types.uint(1),
        types.uint(1)
      ], deployer.address)
    ]);
    
    const character = getCharacterBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(character.name, "John Doe");
    assertEquals(character.description, "A mysterious character");
  }
});

Clarinet.test({
  name: "Test timeline event creation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    // Create project and add event
    let block = chain.mineBlock([
      Tx.contractCall('arc-nest', 'create-project', [
        types.ascii("My Novel")
      ], deployer.address),
      Tx.contractCall('arc-nest', 'add-timeline-event', [
        types.uint(1),
        types.ascii("Chapter 1"),
        types.utf8("The beginning"),
        types.uint(1000)
      ], deployer.address)
    ]);
    
    block.receipts[1].result.expectOk();
    assertEquals(block.receipts[1].result.expectOk(), types.uint(1));
    
    // Verify event details
    let eventBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'get-timeline-event', [
        types.uint(1),
        types.uint(1)
      ], deployer.address)
    ]);
    
    const event = eventBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(event.title, "Chapter 1");
    assertEquals(event.description, "The beginning");
    assertEquals(event.timestamp, types.uint(1000));
  }
});

Clarinet.test({
  name: "Test character relationship creation and validation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    // Setup project and characters
    let setupBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'create-project', [
        types.ascii("My Novel")
      ], deployer.address),
      Tx.contractCall('arc-nest', 'add-character', [
        types.uint(1),
        types.ascii("Character 1"),
        types.utf8("First character")
      ], deployer.address),
      Tx.contractCall('arc-nest', 'add-character', [
        types.uint(1),
        types.ascii("Character 2"),
        types.utf8("Second character")
      ], deployer.address)
    ]);

    // Add relationship between characters
    let relationshipBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'add-character-relationship', [
        types.uint(1),
        types.uint(1),
        types.uint(2),
        types.ascii("Siblings"),
        types.utf8("Brother and sister")
      ], deployer.address)
    ]);

    relationshipBlock.receipts[0].result.expectOk();
    assertEquals(relationshipBlock.receipts[0].result.expectOk(), types.uint(1));

    // Verify relationship details
    let getRelationshipBlock = chain.mineBlock([
      Tx.contractCall('arc-nest', 'get-character-relationship', [
        types.uint(1),
        types.uint(1)
      ], deployer.address)
    ]);

    const relationship = getRelationshipBlock.receipts[0].result.expectOk().expectSome();
    assertEquals(relationship['character1-id'], types.uint(1));
    assertEquals(relationship['character2-id'], types.uint(2));
    assertEquals(relationship['relationship-type'], "Siblings");
  }
});
