# Carbon-Synth

A decentralized synthetic carbon credits and environmental asset trading platform built on the Stacks blockchain using Clarity smart contracts.

## Overview

Carbon-Synth enables the creation, trading, and retirement of synthetic carbon credits in a transparent, secure, and decentralized manner. The platform connects verified carbon credit issuers with buyers looking to offset their carbon footprint.

## Features

### 🌱 Credit Issuance
- **Verified Issuers**: Only whitelisted addresses can issue new carbon credits
- **Project Tracking**: Each credit issuance is linked to a named environmental project
- **Transparent Pricing**: Set custom prices per credit at issuance

### 💱 Trading Marketplace
- **Create Listings**: Sell credits at custom prices
- **Buy Credits**: Purchase credits from active listings
- **Peer-to-Peer Transfers**: Direct credit transfers between accounts
- **Cancel Listings**: Sellers can cancel their active listings

### ♻️ Credit Retirement
- **Permanent Offset**: Retire credits to permanently remove them from circulation
- **Verification**: Track total credits retired for transparency

### 🔒 Security & Governance
- **Access Control**: Owner-managed verified issuer list
- **Balance Validation**: All transfers validate sufficient balances
- **Platform Fees**: Configurable percentage-based fees (default 2%)

## Smart Contract Functions

### Read-Only Functions

#### `(get-balance (account principal))`
Returns the carbon credit balance for a given account.

```clarity
(get-balance 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

#### `(get-project (project-id uint))`
Returns project details including owner, name, total credits, and verification status.

#### `(get-listing (listing-id uint))`
Returns listing information including seller, amount, price, and active status.

#### `(is-verified-issuer (issuer principal))`
Checks if an address is authorized to issue credits.

#### `(get-platform-fee)`
Returns the current platform fee percentage.

#### `(get-total-credits-issued)`
Returns the total number of credits issued on the platform.

#### `(get-total-credits-retired)`
Returns the total number of credits permanently retired.

### Public Functions

#### Admin Functions

##### `(add-verified-issuer (issuer principal))`
**Owner Only** - Adds a new verified issuer to the platform.

```clarity
(contract-call? .carbon-synth add-verified-issuer 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

##### `(update-platform-fee (new-fee uint))`
**Owner Only** - Updates the platform fee percentage.

```clarity
(contract-call? .carbon-synth update-platform-fee u3) ;; Set to 3%
```

#### Credit Management

##### `(issue-credits (project-name (string-ascii 50)) (amount uint) (price uint))`
**Verified Issuers Only** - Issue new carbon credits for a project.

```clarity
(contract-call? .carbon-synth issue-credits "Amazon Reforestation 2025" u1000 u50)
```

##### `(retire-credits (amount uint))`
Permanently retire credits from circulation to offset emissions.

```clarity
(contract-call? .carbon-synth retire-credits u100)
```

#### Trading Functions

##### `(create-listing (amount uint) (price uint))`
Create a new listing to sell credits.

```clarity
(contract-call? .carbon-synth create-listing u500 u55)
```

##### `(buy-credits (listing-id uint) (amount uint))`
Purchase credits from an active listing.

```clarity
(contract-call? .carbon-synth buy-credits u0 u100)
```

##### `(cancel-listing (listing-id uint))`
Cancel your own active listing.

```clarity
(contract-call? .carbon-synth cancel-listing u0)
```

##### `(transfer (amount uint) (recipient principal))`
Transfer credits directly to another account.

```clarity
(contract-call? .carbon-synth transfer u50 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Action requires contract owner |
| u101 | `err-not-found` | Resource not found |
| u102 | `err-insufficient-balance` | Insufficient credit balance |
| u103 | `err-unauthorized` | User not authorized |
| u104 | `err-invalid-amount` | Invalid amount specified |
| u105 | `err-already-verified` | Issuer already verified |
| u106 | `err-not-verified` | Issuer not verified |
| u107 | `err-invalid-price` | Invalid price specified |

## Deployment

### Prerequisites
- Clarinet CLI installed
- Stacks wallet with STX for deployment

### Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd carbon-synth
```

2. **Test the contract**
```bash
clarinet test
```

3. **Deploy to testnet**
```bash
clarinet deploy --testnet
```

4. **Deploy to mainnet**
```bash
clarinet deploy --mainnet
```

## Usage Examples

### Example 1: Setting Up as Platform Owner

```clarity
;; Add verified issuers
(contract-call? .carbon-synth add-verified-issuer 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
(contract-call? .carbon-synth add-verified-issuer 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE)

;; Update platform fee if needed
(contract-call? .carbon-synth update-platform-fee u3)
```

### Example 2: Issuing Credits (Verified Issuer)

```clarity
;; Issue 10,000 credits for a solar farm project at 45 STX per credit
(contract-call? .carbon-synth issue-credits "Solar Farm India 2025" u10000 u45)
```

### Example 3: Trading Credits

```clarity
;; Create a listing to sell 500 credits at 50 STX each
(contract-call? .carbon-synth create-listing u500 u50)

;; Buy 100 credits from listing #0
(contract-call? .carbon-synth buy-credits u0 u100)
```

### Example 4: Offsetting Emissions

```clarity
;; Retire 250 credits to offset your carbon footprint
(contract-call? .carbon-synth retire-credits u250)

;; Check total retired credits
(contract-call? .carbon-synth get-total-credits-retired)
```

## Platform Economics

- **Platform Fee**: 2% default (adjustable by owner)
- **Fee Distribution**: Fees are calculated on each trade
- **Credit Supply**: Controlled by verified issuers only
- **Retirement**: Credits can be permanently retired, reducing supply

## Security Considerations

1. **Verified Issuers**: Only approved addresses can create new credits
2. **Balance Checks**: All transfers validate sufficient balances before execution
3. **Authorization**: Listing management restricted to original creators
4. **No Reentrancy**: Clarity's design prevents reentrancy attacks
5. **Immutable Retirement**: Retired credits cannot be recovered

## Roadmap

- [ ] Multi-token support for different credit types
- [ ] Oracle integration for real-world carbon data
- [ ] Batch operations for efficiency
- [ ] NFT certificates for retired credits
- [ ] Governance token for platform decisions
- [ ] Cross-chain bridge support

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Disclaimer

This smart contract is provided as-is. Users should conduct their own security audits before using in production. Carbon credits issued on this platform are synthetic and may not represent real-world carbon offsets unless verified by the issuer.

---

**Built with ❤️ for a sustainable future on Stacks blockchain**