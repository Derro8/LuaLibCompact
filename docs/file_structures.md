# File Formats

## LPKG

| Value Key  | Byte Size |
| ---------- | ----------- |
| Name Size  | 0x01  |
| Version Size  | 0x01  |
| Name | Name Size |
| Version | Version Size |
| Scripts Format | indefinite |

## Scripts

| Value Key | Byte Size |
| --------- | --------- |
| Name      | NULL TERM |
| Bytecode Size | 0x08  |
| Bytecode  | Bytecode Size |
