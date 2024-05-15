import { useCurrentAccount } from "@mysten/dapp-kit";
import { Container, Flex, Heading, Text } from "@radix-ui/themes";
import { OwnedObjects } from "./OwnedObjects";
import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";

import { SendSui } from "./SendSui";
import { GetFreeCoin } from "./GetFreeCoin";
import { GetCoinBalance } from "./GetCoinBalance";

// use getFullnodeUrl to define Devnet RPC location
const rpcUrl = getFullnodeUrl('testnet');
 
// create a client connected to testnet
const client = new SuiClient({ url: rpcUrl });

  
export function WalletStatus() {
  const account = useCurrentAccount();

  return (
    <Container my="2">
      <Heading mb="2">Wallet Status</Heading>

      {account ? (
        <Flex direction="column">
          <Text>Wallet connected</Text>
          <Text>Address: {account.address}</Text>
        </Flex>
      ) : (
        <Text>Wallet not connected</Text>
      )}
      <SendSui />
      <br/>
      <GetFreeCoin />
      <br/>
      <GetCoinBalance />
      <br/>
      <OwnedObjects />
    </Container>
  );
}
