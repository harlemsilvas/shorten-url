package dev.harlemsilva.EncurtaAI.Links;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "links_dos_otarios")
public class Link {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String urlLong;
    private String urlEncurtada;
    private String urlQrCode;
    private LocalDateTime urlCriadaEm;

    // Construtor sem-argumentos necessário para JPA
    public Link() {
    }

    // Construtor completo
    public Link(Long id, String urlLong, String urlEncurtada, String urlQrCode, LocalDateTime urlCriadaEm) {
        this.id = id;
        this.urlLong = urlLong;
        this.urlEncurtada = urlEncurtada;
        this.urlQrCode = urlQrCode;
        this.urlCriadaEm = urlCriadaEm;
    }

    public Link(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUrlLong() {
        return urlLong;
    }

    public void setUrlLong(String urlLong) {
        this.urlLong = urlLong;
    }

    public String getUrlEncurtada() {
        return urlEncurtada;
    }

    public void setUrlEncurtada(String urlEncurtada) {
        this.urlEncurtada = urlEncurtada;
    }

    // Getter/Setter corrigidos para urlQrCode (antes havia typo getUrlQeCode/setUrlQeCode)
    public String getUrlQrCode() {
        return urlQrCode;
    }

    public void setUrlQrCode(String urlQrCode) {
        this.urlQrCode = urlQrCode;
    }

    public LocalDateTime getUrlCriadaEm() {
        return urlCriadaEm;
    }

    public void setUrlCriadaEm(LocalDateTime urlCriadaEm) {
        this.urlCriadaEm = urlCriadaEm;
    }
}
