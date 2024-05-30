module digital_contract::groth16_test {
    use sui::groth16;
    use sui::event;

    /// Event on whether the proof is verified
    public struct VerifiedEvent has copy, drop {
        is_verified: bool,
    }

    //
    public entry fun verify_proof(vk_bytes: vector<u8>, public_inputs_bytes: vector<u8>, proof_points_bytes: vector<u8>) {
        let pvk = groth16::prepare_verifying_key(&groth16::bn254(), &vk_bytes);
        let public_inputs = groth16::public_proof_inputs_from_bytes(public_inputs_bytes);
        let proof_points = groth16::proof_points_from_bytes(proof_points_bytes);
        event::emit(VerifiedEvent {is_verified: groth16::verify_groth16_proof(&groth16::bn254(), &pvk, &public_inputs, &proof_points)});
    }

/*
    public entry fun verify_proof(public_inputs_bytes: vector<u8>, proof_points_bytes: vector<u8>, ctx: &mut tx_context::TxContext) {
    let vk = x"806…";
    let pvk = groth16::prepare_verifying_key(&groth16::bn254(), &vk);
    let public_inputs = groth16::public_proof_inputs_from_bytes(public_inputs_bytes);
    let proof_points = groth16::proof_points_from_bytes(proof_points_bytes);
    assert!(groth16::verify_groth16_proof(&groth16::bn254(), &pvk, &public_inputs, &proof_points), 0);
    event::emit(Flag { user: tx_context::sender(ctx) });
}
*/
}