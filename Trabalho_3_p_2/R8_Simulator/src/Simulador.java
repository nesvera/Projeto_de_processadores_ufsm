/*
* @(#)Simulador.java  1.0  30/03/2001
*	
* @autor Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

import java.util.*;
import java.io.*;
import javax.swing.*;

/**
* <i>Simulador</i> seleciona a arquitetura e executa o simulador a partir da descri��o
* contida no arquivo da arquitetura.
*/

/* �ltimas atualiza��es:
*
* 16/11/01 
* -> Inser��o das fun��es INF2 e SUP2 que fazem a compara��o entre valores em complememto de 2.
* -> Corre��o do bug na instru��o NOT
*
* 11/12/01
* -> Acr�scimo da op��o de informar a linha que se deseja visualizar na tabela mem�ria ou na
* tabela de vari�veis.
*
* 10/01/02
* -> Calculo correto das linhas visiveis da tabela Mem�ria.
*
* 04/04/02
* -> Escrita em ordem dos endereco dos Labels no arquivo TXT (altera��o no arquivos.c [Montado]).
*
* 18/04/02
* -> Inclus�o das fun��es de JMPD10 e JMPDC10, ou seja, deslocamento de 10bits incondicional e
* condicional a um flag.
*
* 19/04/02
* -> Continua��o do conserto das fun��es JMPD10 e JMPDC10
*
* 11/05/02
* -> Inclus�o da Instru��o IGNORE
*
* 16/05/02
* -> Recebe o c�digo montado original e altera a ordem destro do simulador, e n�o no montador
* como estava ocorrendo anteriormente.
*
* -> Inclui a instrucao de SL0C,SL1C,SR0C,SR1C,LDRI,STRI,JALR,SLT,SKPEQ,SKPNE,
* SKPEQI e SKPNEI.
*
* -> Conserto no scroll da tabela que contem a mem�ria.
*
* -> Conserto nas instru��es ADDI e SUBI, que n�o possui ext_sinal
*
* 27/05/02
* -> Inclus�o da instru��o STSP e modifica��o na execu��o da LDSP.
*
* 28/05/02
* -> Seleciona a posi��o da mem�ria apontada pela pr�xima instru��o.
*
* -> Op��o NOT da pilha, que refere-se quando a pilha n�o � utilizada no processador.
*
* 08/07/02
* -> Conserto da instru��o SLT.
*
* 05/05/03
* -> Insercao do teste de verificacao de constantes terminadas em H e B. Antes se uma palavra
* comecava por # e terminava por H ou B esta era automaticamente uma constante. Agora se a 
* palavra tem estas caracteristicas eh realizado o teste isHexadecimal e isBinario que determina 
* se a palavra realmente eh H ou B.
*
* 12/05/03 e 13/03/2003
* -> Modifica a leitura dos campos de montagem na Arquitetura.
* -> Inser��o da op��o do registrador de mascara.
* -> Inser��o das instru��es da R11.
* -> Acesso as linhas das tabelas em Hexa.
*
* 15/05/03
* -> Inser��o do breakpoint
* -> Conserto da instru��o CMP
* -> Inser��o de soma e subtra��o em bin�rio.
*
* 19/05/03
* -> Conserto da fun��o decimal_binario da classe Convers�o, que n�o estava funcionando 
*    adequadamente para n�meros negativos.
*
* 29/09/03
*	-> Conserto na instru��o MOV
* 
* 30/09/03
* -> Conserto para trabalhar com instru��es IGNORE no m�todo selecionaInstrucao da classe
*    Arquitetura.
*
* 31/10/03
* -> Conserto no m�todo substituiPseudoLabelMemoria(int nsubstitui) da classe Substitui
*    Esse m�todo continha um erro que resultava na montagem incorreta da mem�ria de dados.
*    Exemplo:   ASM     >> END1: DB A1,A1,#0003H
*                          A1: DB #AAAAH
*               memoria >> 0001  END1  AAAAAAAA
*
* 04/11/03
* -> Conserto do erro causado pela �ltima altera��o no m�todo substituiPseudoLabelMemoria
* da classe Substitui.
*
* 13/11/03
* -> Modifica��o no c�digo da instru��o LDIM no arquivo de configura��o da R12.
*/
public class Simulador 
{
	private Conversao conversao;
	private Memoria memoria,memoriadados;
	private Variaveis variaveis;
	private	Janela janela;
	private Arquivo arquivo;
	private Arquitetura arquitetura;
	private Execucao execucao;
	private int tamanhoMemoria;
	private int numeroVariaveis;
	private int tamanhoPalavra;
	private int nflag;
	private String posicaoSP,nomeArquitetura,movpilha,tipoArquitetura,mask;
	private String arqarq;

	public Simulador(String arquitetura)
	{
		arqarq=arquitetura;
	}
	public static void main(String s[])
	{
		String arquitetura;
		try
		{
			arquitetura=s[0];
			if(arquitetura.length()>4)
			{
				if(!arquitetura.substring(arquitetura.length()-4,arquitetura.length()).equalsIgnoreCase(".arq"))
					arquitetura=arquitetura.concat(".arq");
			}
			else
			{
				arquitetura=arquitetura.concat(".arq");
			}
			Simulador sim=new Simulador(arquitetura);
			sim.implementa();
		}catch(ArrayIndexOutOfBoundsException e )
		{
			Configurador config=new Configurador();
		}
	}

	//Retorna as variaveis
	public Conversao getConversao(){return conversao;}
	public Memoria getMemoria(){return memoria;}
	public Memoria getMemoriaDados(){return memoriadados;}
	public Variaveis getVariaveis(){return variaveis;}
	public Janela getJanela(){return janela;}
	public Arquivo getArquivo(){return arquivo;}
	public Arquitetura getArquitetura(){return arquitetura;}
	public Execucao getExecucao(){return execucao;}
	public String getNomeArquitetura(){return nomeArquitetura;}
	public String getTipoArquitetura(){return tipoArquitetura;}
	public String  getMovPilha() {return movpilha;}
	public int getTamanhoMemoria(){return tamanhoMemoria;}
	public int getNumeroVariaveis(){return numeroVariaveis;}
	public String getPosicaoSP(){return posicaoSP;}
	public int getNflag(){return nflag;}
	public void setMascara(String mascara){janela.setMascara(mascara);}
	public String getMascara(){return janela.getMascara();}
	
	//Seta as variaveis
	public void setTamanhoMemoria(int t){tamanhoMemoria=t;}
	public void setNumeroVariaveis(int n){numeroVariaveis=n;}
	
	/**
	* Implementa o Simulador.
	*/
	public boolean implementa()
	{
		int nreg=0;
		boolean pc,ir,sp;
		String[]flags;
		String linha;
		StringTokenizer st;
		
		flags=new String[10];
		nflag=0;
		movpilha="";
		
		try
		{
			//Abre o arquivo para leitura.
			FileInputStream files=new FileInputStream(arqarq);
			DataInputStream d=new DataInputStream(files);
			BufferedReader dis = new BufferedReader(new InputStreamReader(files));
		  
		  //NOME ARQUITETURA
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$ARQ"));
			linha=dis.readLine();
			st=new StringTokenizer(linha);
			nomeArquitetura=st.nextToken();
			
			//ARQUITETURA
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$ARQUITETURA"));
			linha=dis.readLine();
			st=new StringTokenizer(linha);
			linha=st.nextToken();
			tipoArquitetura="";
			tipoArquitetura=linha;
				
			//TAMANHO MEMORIA
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$TAMMEMORIA"));
			linha=dis.readLine();
			st=new StringTokenizer(linha);
			linha=st.nextToken();
			tamanhoMemoria=Integer.valueOf(linha).intValue();

			//REGS
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$REG"));
			linha=dis.readLine();
		  	st=new StringTokenizer(linha);
			linha=st.nextToken();
			nreg = Integer.valueOf(linha).intValue();

			//MASK
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$MASK"));
			linha=dis.readLine();
			st=new StringTokenizer(linha);
			mask=st.nextToken();
			
			//FLAGS
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$FLAG"));
			linha=dis.readLine();
			while(!linha.equalsIgnoreCase("$ENDFLAG"))
			{
				st=new StringTokenizer(linha);
				linha=st.nextToken();
				flags[nflag]=linha;
				nflag++;
				linha=dis.readLine();
			}
			
			//PILHA
			do
			{
				linha=dis.readLine();
			}while(!linha.equalsIgnoreCase("$PILHA"));
			linha=dis.readLine();
			st=new StringTokenizer(linha);
			linha=st.nextToken();
			movpilha=linha;
			
			dis.close();
			
			//EXIBE
			/*
			System.out.println("nomearq="+nomeArquitetura);
			System.out.println("tipoarq="+tipoArquitetura);
			System.out.println("tammem="+tamanhoMemoria);
			System.out.println("nreg="+nreg);
			System.out.println("nflag="+nflag);
			for(int i=0;i<nflag;i++)
				System.out.println(flags[i]);
			System.out.println("movpilha="+movpilha);
			*/
		}
		catch(FileNotFoundException f)
		{
			JOptionPane.showMessageDialog(null,"A ARQUITETURA N�O ENCONTRADA","MENSAGEM DE ERRO", JOptionPane.ERROR_MESSAGE);
			return false;
		}
		catch(Exception e)
		{
			JOptionPane.showMessageDialog(null,"ARQUIVO DE CONFIGURA��O DA ARQUITETURA APRESENTA ERRO.","MENSAGEM DE ERRO", JOptionPane.ERROR_MESSAGE);
			return false;
		}
		
		conversao=new Conversao();
		
		numeroVariaveis=100; //Default	
		if(movpilha.equalsIgnoreCase("INC"))
			posicaoSP=conversao.decimal_hexa(tamanhoMemoria-((tamanhoMemoria/100)*10));
		else if(movpilha.equalsIgnoreCase("DEC"))
			posicaoSP=conversao.decimal_hexa(tamanhoMemoria-1);
			
	
		memoria=new Memoria(this);
		if(isHarvard())
			memoriadados=new Memoria(this);
		
		variaveis=new Variaveis(this);
		
		arquivo=new Arquivo(this,arqarq);
		
		arquitetura=new Arquitetura(this,arqarq);
		
		execucao=new Execucao(this,arquitetura);
		
		janela =new Janela(this,nreg,nflag,flags);
		return true;
	}
	
	/**
	* Verifica se a arquitetura � HARVARD
	*/
	public boolean isHarvard()
	{
		if(tipoArquitetura.equalsIgnoreCase("HARVARD"))
			return true;
		return false;
	}

	/**
	* Verifica se a arquitetura tem registrador de mascara.
	*/
	public boolean isMask()
	{
		if(mask.equalsIgnoreCase("YES"))
			return true;
		return false;
	}
	
	/**
	* Inicializa a janela do Simulador.
	*/
	public void inicializa()
	{
		janela.inicializa();	
		memoria.inicializa();
		variaveis.inicializa();
		if(isHarvard())
			memoriadados.inicializa();
	}
}