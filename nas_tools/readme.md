# 🗄️ Virtualização de um Serviço NAS

Este projeto simula um ambiente NAS (Network Attached Storage) utilizando Docker e Bash.  
Discos são virtualizados como arquivos, organizados em RAID com `mdadm`, e disponibilizados via **FTP**, **SMB** e **SSH** — tudo acessado por um menu interativo.

---

![Exemplo do Menu Interativo](nas_sm.png)

---

## Funcionalidades

- Criação e remoção de discos virtuais usando loop devices 
- Montagem automática de discos virtuais  
- Organização em arrays RAID (RAID 0, 1, 5, 10 etc.) com `mdadm`  
- Criação e remoção de volumes e usuários  
- Compartilhamento dos volumes via:  
  - **FTP** (pure-ftpd)  
  - **SMB** (Samba)  
  - **SSH** (acesso à interface de controle via terminal)  
---

## Tecnologias utilizadas

- Bash Script  para desenvolvimento do menu interativo
- Docker       para virtualização do ambiente NAS
- Loop Devices para simular discos virtuais
- mdadm        para gerenciamento de arrays RAID
- pure-ftpd    para serviço FTP
- Samba        para serviço SMB
- OpenSSH      ara SSH access
- tcc (Tiny C Compiler) para compilação de scripts em C
---

## Como rodar

### 1° Construir a imagem Docker

```bash
sudo docker build -t nas-image .
```

### 2️° Executar o container

```bash
sudo docker run -it --rm --privileged \
  -p 22:22 -p 21:21 -p 139:139 -p 445:445 \
  nas-image
```

> ⚠️ `--privileged` é obrigatório para usar loop devices e RAID dentro do container.

---

## 3° Como usar

1. Conecte-se ao container via **SSH** senha: **toor**: 

```bash 
ssh ssh_user@localhost -p 22
```

2. execute o script para acessar o menu interativo:

```bash
run_app
```


## Organização dos volumes

Os volumes criados são montados em **/media/{userName}/{volumeName}** automaticamente e acessíveis via:

- **FTP** – porta 21  
- **SMB** – portas 139 e 445  
---


## Licença

Projeto desenvolvido para fins acadêmicos.  
**Sem licença de distribuição.**
