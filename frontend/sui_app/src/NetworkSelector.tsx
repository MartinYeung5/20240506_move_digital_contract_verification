import { useSuiClient } from '@mysten/dapp-kit';

function NetworkSelector() {
    const client = useSuiClient();
	const ctx = useSuiClientContext();
 
	return (
		<div>
			{Object.keys(ctx.networks).map((network) => (
				<button key={network} onClick={() => ctx.selectNetwork(network)}>
					{`select ${network}`}
				</button>
			))}
		</div>
	);
}