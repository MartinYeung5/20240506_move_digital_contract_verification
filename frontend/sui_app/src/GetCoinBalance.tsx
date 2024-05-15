import { getFullnodeUrl, SuiClient } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';
import { useCurrentAccount, useSignAndExecuteTransactionBlock } from '@mysten/dapp-kit';
import { Container, Flex, Heading, Text } from "@radix-ui/themes";
import { useState } from 'react';

// use getFullnodeUrl to define Devnet RPC location
const rpcUrl = getFullnodeUrl('testnet');
 
// create a client connected to devnet
const client = new SuiClient({ url: rpcUrl });
 
// get coins owned by an address
// replace <OWNER_ADDRESS> with actual address in the form of 0x123...

//await client.getCoins({
//	owner: '0x440a564c98eaa78c4f791a0d5642a833f32b8d33b71731ea35074435f04eb088',
//	coinType:""
//});

/*
await client.getOwnedObjects({
	owner:"0x440a564c98eaa78c4f",
	filter: {
		StructType: ``
	}
})
*/

// queryEvents


export function GetCoinBalance() {

	const account = useCurrentAccount();
	const [YY, setYY] = useState("");
	
    async function getMyCoinInfo() {
        const XX = await client.getCoins({
			owner:account!.address,
			coinType:"0xb564841a2b36b9e350bb0bbde52ac34310e2f6b0eed2cd0efe76eeb53d88d399::faucetucoin::FAUCETUCOIN"
		})
		setYY(XX);
		return XX;
	}
	getMyCoinInfo();

	return (<Container my="2">
		{account ? (
        <Flex direction="column">
          <Text>Address: {account.address}</Text>
		  {YY!="undefined" ? (<Text>{YY}</Text>):
		  (<Text>N/A</Text>)}
        </Flex>
      ) : (
        <Text>testing</Text>
      )}
	</Container>
	)
}