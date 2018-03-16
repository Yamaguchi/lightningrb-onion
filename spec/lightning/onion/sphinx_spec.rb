# frozen_string_literal: true

require 'spec_helper'

describe Lightning::Onion::Sphinx do
  let(:public_keys) do
    [
      '02eec7245d6b7d2ccb30380bfbe2a3648cd7a942653f5aa340edcea1f283686619',
      '0324653eac434488002cc06bbfb7f10fe18991e35f9fe4302dbea6d2353dc0ab1c',
      '027f31ebc5462c1fdce1b737ecff52d37d75dea43ce11c74d25aa297165faa2007',
      '032c0b7cf95324a07d05398b240174dc0c2be444d96b159aa6c7f7b1e668680991',
      '02edabbd16b41c8371b92ef2f04c1185b4f03b6dcd52ba9b78d9d7c89c8f221145',
    ]
  end
  let(:session_key) { '4141414141414141414141414141414141414141414141414141414141414141' }

  describe '.compute_ephemereal_public_keys_and_shared_secrets' do
    subject { described_class.compute_ephemereal_public_keys_and_shared_secrets(session_key, public_keys) }

    # hop_shared_secret[0] = 0x53eb63ea8a3fec3b3cd433b85cd62a4b145e1dda09391b348c4e1cd36a03ea66
    # hop_blinding_factor[0] = 0x2ec2e5da605776054187180343287683aa6a51b4b1c04d6dd49c45d8cffb3c36
    # hop_ephemeral_pubkey[0] = 0x02eec7245d6b7d2ccb30380bfbe2a3648cd7a942653f5aa340edcea1f283686619
    #
    # hop_shared_secret[1] = 0xa6519e98832a0b179f62123b3567c106db99ee37bef036e783263602f3488fae
    # hop_blinding_factor[1] = 0xbf66c28bc22e598cfd574a1931a2bafbca09163df2261e6d0056b2610dab938f
    # hop_ephemeral_pubkey[1] = 0x028f9438bfbf7feac2e108d677e3a82da596be706cc1cf342b75c7b7e22bf4e6e2
    #
    # hop_shared_secret[2] = 0x3a6b412548762f0dbccce5c7ae7bb8147d1caf9b5471c34120b30bc9c04891cc
    # hop_blinding_factor[2] = 0xa1f2dadd184eb1627049673f18c6325814384facdee5bfd935d9cb031a1698a5
    # hop_ephemeral_pubkey[2] = 0x03bfd8225241ea71cd0843db7709f4c222f62ff2d4516fd38b39914ab6b83e0da0
    #
    # hop_shared_secret[3] = 0x21e13c2d7cfe7e18836df50872466117a295783ab8aab0e7ecc8c725503ad02d
    # hop_blinding_factor[3] = 0x7cfe0b699f35525029ae0fa437c69d0f20f7ed4e3916133f9cacbb13c82ff262
    # hop_ephemeral_pubkey[3] = 0x031dde6926381289671300239ea8e57ffaf9bebd05b9a5b95beaf07af05cd43595
    #
    # hop_shared_secret[4] = 0xb5756b9b542727dbafc6765a49488b023a725d631af688fc031217e90770c328
    # hop_blinding_factor[4] = 0xc96e00dddaf57e7edcd4fb5954be5b65b09f17cb6d20651b4e90315be5779205
    # hop_ephemeral_pubkey[4] = 0x03a214ebd875aab6ddfd77f22c5e7311d7f77f17a169e599f157bbcdae8bf071f4
    it { expect(subject[0][0]).to eq '02eec7245d6b7d2ccb30380bfbe2a3648cd7a942653f5aa340edcea1f283686619' }
    it { expect(subject[1][0]).to eq '53eb63ea8a3fec3b3cd433b85cd62a4b145e1dda09391b348c4e1cd36a03ea66' }
    it { expect(subject[0][1]).to eq '028f9438bfbf7feac2e108d677e3a82da596be706cc1cf342b75c7b7e22bf4e6e2' }
    it { expect(subject[1][1]).to eq 'a6519e98832a0b179f62123b3567c106db99ee37bef036e783263602f3488fae' }
    it { expect(subject[0][2]).to eq '03bfd8225241ea71cd0843db7709f4c222f62ff2d4516fd38b39914ab6b83e0da0' }
    it { expect(subject[1][2]).to eq '3a6b412548762f0dbccce5c7ae7bb8147d1caf9b5471c34120b30bc9c04891cc' }
    it { expect(subject[0][3]).to eq '031dde6926381289671300239ea8e57ffaf9bebd05b9a5b95beaf07af05cd43595' }
    it { expect(subject[1][3]).to eq '21e13c2d7cfe7e18836df50872466117a295783ab8aab0e7ecc8c725503ad02d' }
    it { expect(subject[0][4]).to eq '03a214ebd875aab6ddfd77f22c5e7311d7f77f17a169e599f157bbcdae8bf071f4' }
    it { expect(subject[1][4]).to eq 'b5756b9b542727dbafc6765a49488b023a725d631af688fc031217e90770c328' }
  end

  describe '.generate_cipher_stream' do
    let(:expected) do
      'e5f14350c2a76fc232b5e46d421e9615471ab9e0bc887beff8c95fdb878f7b3a' \
      '7141453e5f8d22b6351810ae541ce499a09b4a9d9f80d1845c8960c85fc6d1a8' \
      '7bd24b2ce49922898e9353fa268086c00ae8b7f718405b72ad380cdbb38c85e0' \
      '2a00427eb4bdbda8fcd42b44708a9efde49cf753b75ebb389bf84d0bfbf58590' \
      'e510e034572a01e409c30939e2e4a090ecc89c371820af54e06e4ad5495d4e58' \
      '718385cca5414552e078fedf284fdc2cc5c070cba21a6a8d4b77525ddbc9a9fc' \
      'a9b2f29aac5783ee8badd709f81c73ff60556cf2ee623af073b5a84799acc1ca' \
      '46b764f74b97068c7826cc0579794a540d7a55e49eac26a6930340132e946a98' \
      '3240b0cd1b732e305c1042f590c4b26f140fc1cab3ee6f620958e0979f85eddf' \
      '586c410ce42e93a4d7c803ead45fc47cf4396d284632314d789e73cf3f534126' \
      'c63fe244069d9e8a7c4f98e7e530fc588e648ef4e641364981b5377542d5e7a4' \
      'aaab6d35f6df7d3a9d7ca715213599ee02c4dbea4dc78860febe1d29259c64b5' \
      '9b3333ffdaebbaff4e7b31c27a3791f6bf848a58df7c69bb2b1852d2ad357b99' \
      '19ffdae570b27dc709fba087273d3a4de9e6a6be66db647fb6a8d1a503b3f481' \
      'befb96745abf5cc4a6bba0f780d5c7759b9e303a2a6b17eb05b6e660f4c47495' \
      '9db183e1cae060e1639227ee0bca03978a238dc4352ed764da7d4f3ed5337f6d' \
      '0376dff72615beeeeaaeef79ab93e4bcbf18cd8424eb2b6ad7f33d2b4ffd5ea0' \
      '8372e6ed1d984152df17e04c6f73540988d7dd979e020424a163c271151a2559' \
      '66be7edef42167b8facca633649739bab97572b485658cde409e5d4a0f653f1a' \
      '5911141634e3d2b6079b19347df66f9820755fd517092dae62fb278b0bafcc7a' \
      'd682f7921b3a455e0c6369988779e26f0458b31bffd7e4e5bfb31944e80f100b' \
      '2553c3b616e75be18328dc430f6618d55cd7d0962bb916d26ed4b117c46fa29e' \
      '0a112c02c36020b34a96762db628fa3490828ec2079962ad816ef20ea0bca78f' \
      'b2b7f7aedd4c47e375e64294d151ff03083730336dea64934003a27730cc1c7d' \
      'ec5049ddba8188123dd191aa71390d43a49fb792a3da7082efa6cced73f00ecc' \
      'ea18145fbc84925349f7b552314ab8ed4c491e392aed3b1f03eb79474c294b42' \
      'e2eba1528da26450aa592cba7ea22e965c54dff0fd6fdfd6b52b9a0f5f762e27' \
      'fb0e6c3cd326a1ca1c5973de9be881439f702830affeb0c034c18ac8d5c2f135' \
      'c964bf69de50d6e99bde88e90321ba843d9753c8f83666105d25fafb1a11ea22' \
      'd62ef6f1fc34ca4e60c35d69773a104d9a44728c08c20b6314327301a2c400a7' \
      '1e1424c12628cf9f4a67990ade8a2203b0edb96c6082d4673b7309cd52c4b32b' \
      '02951db2f66c6c72bd6c7eac2b50b83830c75cdfc3d6e9c2b592c45ed5fa5f6e' \
      'c0da85710b7e1562aea363e28665835791dc574d9a70b2e5e2b9973ab590d45b' \
      '94d244fc4256926c5a55b01cd0aca21fe5f9c907691fb026d0c56788b03ca3f0' \
      '8db0abb9f901098dde2ec4003568bc3ca27475ff86a7cb0aabd9e5136c5de064' \
      'd16774584b252024109bb02004dba1fabf9e8277de097a0ab0dc8f6e26fcd4a2' \
      '8fb9d27cd4a2f6b13e276ed259a39e1c7e60f3c32c5cc4c4f96bd981edcb5e2c' \
      '76a517cdc285aa2ca571d1e3d463ecd7614ae227df17af7445305bd7c661cf7d' \
      'ba658b0adcf36b0084b74a5fa408e272f703770ac5351334709112c5d4e4fe98' \
      '7e0c27b670412696f52b33245c229775da550729938268ee4e7a282e4a60b25d' \
      'bb28ea8877a5069f819e5d1d31d9140bbc627ff3989115ade30d309374fea843' \
      '5815418038534d12e4ffe88b91406a71d89d5a083e3b8224d86b2be11be32169' \
      'afb04b9ea997854be9085472c342ef5fca19bf5479'
    end
    let(:key) { 'ce496ec94def95aadd4bec15cdb41a740c9f2b62347c4917325fcc6fb0453986'.htb }
    subject { described_class.generate_cipher_stream(key, 1365).bth }
    it { is_expected.to eq expected }
  end

  describe '.generate_filler' do
    # filler =
    # 0xc6b008cf6414ed6e4c42c291eb505e9f22f5fe7d0ecdd15a833f4d016ac974
    # d33adc6ea3293e20859e87ebfb937ba406abd025d14af692b12e9c9c2adbe307
    # a679779259676211c071e614fdb386d1ff02db223a5b2fae03df68d321c7b29f
    # 7c7240edd3fa1b7cb6903f89dc01abf41b2eb0b49b6b8d73bb0774b58204c0d0
    # e96d3cce45ad75406be0bc009e327b3e712a4bd178609c00b41da2daf8a4b0e1
    # 319f07a492ab4efb056f0f599f75e6dc7e0d10ce1cf59088ab6e873de3773438
    # 80f7a24f0e36731a0b72092f8d5bc8cd346762e93b2bf203d00264e4bc136fc1
    # 42de8f7b69154deb05854ea88e2d7506222c95ba1aab065c8a851391377d3406
    # a35a9af3ac
    let(:shared_secrets) do
      described_class.compute_ephemereal_public_keys_and_shared_secrets(session_key, public_keys)[1]
    end
    let(:key_type) { 'rho' }
    let(:expected) do
      'c6b008cf6414ed6e4c42c291eb505e9f22f5fe7d0ecdd15a833f4d016ac974d3' \
      '3adc6ea3293e20859e87ebfb937ba406abd025d14af692b12e9c9c2adbe307a6' \
      '79779259676211c071e614fdb386d1ff02db223a5b2fae03df68d321c7b29f7c' \
      '7240edd3fa1b7cb6903f89dc01abf41b2eb0b49b6b8d73bb0774b58204c0d0e9' \
      '6d3cce45ad75406be0bc009e327b3e712a4bd178609c00b41da2daf8a4b0e131' \
      '9f07a492ab4efb056f0f599f75e6dc7e0d10ce1cf59088ab6e873de377343880' \
      'f7a24f0e36731a0b72092f8d5bc8cd346762e93b2bf203d00264e4bc136fc142' \
      'de8f7b69154deb05854ea88e2d7506222c95ba1aab065c8a851391377d3406a3' \
      '5a9af3ac'
    end
    let(:payload_length) { 33 }
    let(:mac_length) { 32 }
    subject { described_class.generate_filler(key_type, shared_secrets[0...-1], payload_length + mac_length, 20) }
    it { expect(subject.size).to eq expected.size }
    it { is_expected.to eq expected }
  end
end
