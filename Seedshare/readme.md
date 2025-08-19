# Community Garden Resource Allocation Contract

A tokenized community garden management system built on the Stacks blockchain using Clarity smart contracts. This contract enables transparent distribution of garden resources (seeds, tools, etc.) while preventing double claims and ensuring fair allocation among approved gardeners.

## 🌱 Overview

This smart contract manages a community garden by:
- Tokenizing garden resources using fungible tokens
- Managing approved gardener memberships
- Distributing resources fairly to approved members
- Preventing duplicate claims
- Tracking resource allocation and usage
- Allowing reclamation of unused resources after harvest periods

## 🔧 Contract Features

### Resource Management
- **Tokenized Resources**: Garden resources are represented as fungible tokens
- **Fair Distribution**: Each approved gardener receives a predetermined allocation
- **Claim Prevention**: Built-in mechanisms prevent double-claiming of resources
- **Seasonal Management**: Resources are distributed based on active growing seasons

### Access Control
- **Garden Coordinator**: Designated administrator with management privileges
- **Approved Gardeners**: Vetted community members eligible for resource allocation
- **Bulk Operations**: Efficient approval of multiple gardeners simultaneously

### Activity Logging
- **Transparent Operations**: All major activities are logged with descriptions
- **Audit Trail**: Complete history of approvals, distributions, and administrative actions

## 📋 Contract Functions

### Administrative Functions (Coordinator Only)

#### `approve-gardener`
```clarity
(approve-gardener (gardener-address principal))
```
Approves a new gardener for resource allocation eligibility.

#### `revoke-gardener-approval`
```clarity
(revoke-gardener-approval (gardener-address principal))
```
Revokes approval for an existing gardener.

#### `bulk-approve-gardeners`
```clarity
(bulk-approve-gardeners (gardener-addresses (list 200 principal)))
```
Approves multiple gardeners in a single transaction (up to 200).

#### `update-resource-allocation`
```clarity
(update-resource-allocation (new-allocation uint))
```
Updates the resource allocation amount per gardener.

#### `update-harvest-period`
```clarity
(update-harvest-period (new-period uint))
```
Updates the harvest season length (in blocks).

#### `reclaim-unused-resources`
```clarity
(reclaim-unused-resources)
```
Burns unused resources after the harvest period ends.

### Gardener Functions

#### `claim-garden-resources`
```clarity
(claim-garden-resources)
```
Allows approved gardeners to claim their allocated resources (one-time per season).

### Read-Only Functions

- `get-season-active-status`: Check if the current season is active
- `is-gardener-approved`: Verify if a gardener is approved
- `has-gardener-claimed-resources`: Check if a gardener has already claimed resources
- `get-gardener-allocated-amount`: Get the amount allocated to a specific gardener
- `get-total-resources-distributed`: Get total resources distributed so far
- `get-resource-allocation-per-gardener`: Get current allocation per gardener
- `get-harvest-period`: Get current harvest period length
- `get-season-start-block`: Get the block when the season started
- `get-garden-activity`: Retrieve logged activity by ID

## 🚀 Deployment & Setup

### Initial Configuration
The contract is deployed with the following default settings:
- **Total Supply**: 1,000,000,000 garden resource tokens
- **Default Allocation**: 100 tokens per gardener
- **Season Status**: Active
- **Harvest Period**: 10,000 blocks (~69 days on Stacks mainnet)

### Deployment Steps
1. Deploy the contract to the Stacks blockchain
2. The deployer automatically becomes the Garden Coordinator
3. Begin approving gardeners using `approve-gardener`
4. Gardeners can start claiming resources with `claim-garden-resources`

## 📊 Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | `ERROR-NOT-GARDEN-COORDINATOR` | Only the garden coordinator can perform this action |
| u101 | `ERROR-RESOURCES-ALREADY-CLAIMED` | Gardener has already claimed resources this season |
| u102 | `ERROR-GARDENER-NOT-APPROVED` | Gardener is not approved for resource allocation |
| u103 | `ERROR-INSUFFICIENT-GARDEN-RESOURCES` | Not enough resources available for distribution |
| u104 | `ERROR-SEASON-NOT-ACTIVE` | Current season is not active |
| u105 | `ERROR-INVALID-RESOURCE-ALLOCATION` | Invalid allocation amount specified |
| u106 | `ERROR-HARVEST-PERIOD-NOT-ENDED` | Harvest period must end before reclaiming resources |
| u107 | `ERROR-INVALID-GARDENER` | Invalid gardener address or already approved |
| u108 | `ERROR-INVALID-GROWING-PERIOD` | Invalid growing period length |

## 🔐 Security Features

- **Single Claim**: Gardeners can only claim resources once per season
- **Authorization**: Critical functions restricted to the garden coordinator
- **Input Validation**: All inputs are validated before execution
- **Resource Tracking**: Complete audit trail of all resource movements
- **Time-based Controls**: Harvest periods prevent premature resource reclamation

## 💡 Use Cases

### Community Gardens
- Distribute seeds and tools to community members
- Track resource usage and prevent waste
- Ensure fair access to limited resources

### Educational Gardens
- Manage school garden programs
- Track student participation and resource allocation
- Provide transparent resource distribution

### Urban Farming Cooperatives
- Coordinate resource sharing among cooperative members
- Maintain transparent operations
- Enable seasonal resource management

## 🛠 Development

### Prerequisites
- Clarity CLI for local testing
- Stacks blockchain testnet access for deployment testing
- Understanding of Clarity smart contract development

### Testing
```bash
# Install Clarity CLI
npm install -g @stacks/cli

# Test contract functions
clarinet test

# Check contract syntax
clarinet check
```

## 📈 Future Enhancements

- **Multi-season Support**: Manage multiple growing seasons simultaneously
- **Resource Types**: Support different types of garden resources
- **Yield Tracking**: Track harvest yields and resource efficiency
- **Governance**: Community voting on resource allocation policies
- **Integration**: Connect with IoT sensors for automated resource tracking
