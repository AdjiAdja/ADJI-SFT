# Curato

Pasar NFT mini yang kurasinya diputuskan komunitas lewat **quadratic voting**. Proyek portofolio Web3 oleh [@Adji](https://github.com/Adji).

## Inovasi
- **Kurasi quadratic voting**: 100 kredit per ronde (7 hari); n suara pada satu koleksi berbiaya n² kredit, jadi pengaruh satu wallet dibatasi.
- **Pratinjau transaksi bahasa manusia**: pembeli melihat siapa menerima berapa sebelum menandatangani.
- **Royalti on-chain (ERC-2981)** diatur kreator, dibayarkan otomatis saat terjual.
- **Marketplace non-custodial**: NFT tetap di wallet penjual sampai terjual.

## Struktur
- `contracts/` Solidity + Foundry (`CuratoNFT`, `CuratoMarket`, `CuratoCuration`) beserta tes
- `web/index.html` antarmuka statis (mode demo); siap di-host di GitHub Pages

## Menjalankan
```bash
git init && cd contracts
forge install OpenZeppelin/openzeppelin-contracts foundry-rs/forge-std
forge test
```
Deploy ke testnet: `forge create` atau `forge script` ke Base Sepolia / Sepolia, lalu hubungkan alamat kontrak ke frontend.

## Batasan yang diketahui
- Hak suara berdasarkan saldo NFT saat voting; NFT bisa dipindah ke wallet lain untuk memilih lagi. Perbaikan: snapshot saldo per ronde (ERC20Votes-style checkpoint).
- Kontrak belum diaudit. Hanya untuk testnet.

## Roadmap
1. Hubungkan frontend ke kontrak (wagmi/viem), migrasi ke Next.js + TypeScript
2. Listing tanpa gas (order EIP-712)
3. Split royalti ke beberapa wallet
4. Dashboard portofolio dan pengingat voting

## Deploy ke testnet (Base Sepolia)
1. Ambil ETH testnet dari faucet Base Sepolia.
2. Simpan kunci deployer di keystore (jangan taruh private key di repo): `cast wallet import deployer --interactive`
3. Deploy:
```bash
cd contracts
export TREASURY=0xAlamatWalletmu
forge script script/Deploy.s.sol --rpc-url base_sepolia --account deployer --broadcast
```
4. Salin tiga alamat dari log ke objek `CFG` di bagian atas `web/index.html` (`nft`, `market`, `cur`). Selama kosong, situs berjalan di mode demo; setelah terisi, situs membaca dan menulis ke kontrak lewat wallet.
