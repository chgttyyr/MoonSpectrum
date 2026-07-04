from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "competition" / "MoonSpectrum-proposal.pdf"
FONT = Path("C:/Windows/Fonts/msyh.ttc")


def p(text, style):
    return Paragraph(text, style)


def main():
    pdfmetrics.registerFont(TTFont("MSYH", str(FONT)))
    pdfmetrics.registerFont(TTFont("MSYH-Bold", "C:/Windows/Fonts/msyhbd.ttc"))

    styles = {
        "title": ParagraphStyle(
            "title",
            fontName="MSYH-Bold",
            fontSize=18,
            leading=23,
            textColor=colors.HexColor("#16324F"),
            spaceAfter=7,
        ),
        "body": ParagraphStyle(
            "body",
            fontName="MSYH",
            fontSize=9.4,
            leading=13,
            textColor=colors.HexColor("#1F2933"),
        ),
        "section": ParagraphStyle(
            "section",
            fontName="MSYH-Bold",
            fontSize=10.2,
            leading=13,
            textColor=colors.HexColor("#0B5CAD"),
            spaceBefore=4,
            spaceAfter=2,
        ),
        "small": ParagraphStyle(
            "small",
            fontName="MSYH",
            fontSize=8.2,
            leading=11,
            textColor=colors.HexColor("#394B59"),
        ),
    }

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=14 * mm,
        rightMargin=14 * mm,
        topMargin=13 * mm,
        bottomMargin=11 * mm,
    )

    story = [
        p("MoonSpectrum 项目申报书", styles["title"]),
        p(
            "项目方向：科学信号处理基础库 | 参赛类型：原创 MoonBit 生态项目 | 许可证：Apache-2.0",
            styles["small"],
        ),
        Spacer(1, 4),
    ]

    summary = [
        [p("项目名称", styles["body"]), p("MoonSpectrum", styles["body"])],
        [p("GitHub 仓库", styles["body"]), p("https://github.com/Lyhdsba/moonspectrum", styles["body"])],
        [p("GitLink 仓库", styles["body"]), p("创建后与 GitHub 同步，用于赛事审查", styles["body"])],
        [
            p("Mooncakes 状态", styles["body"]),
            p("已检索 fft/fourier/spectrum/wavelet/convolution/iir，未发现直接重合包；后续发布 Lyhdsba/moonspectrum", styles["body"]),
        ],
    ]
    table = Table(summary, colWidths=[29 * mm, 138 * mm])
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), "MSYH"),
                ("FONTNAME", (0, 0), (0, -1), "MSYH-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.5),
                ("LEADING", (0, 0), (-1, -1), 11),
                ("TEXTCOLOR", (0, 0), (0, -1), colors.HexColor("#16324F")),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#B7C4CF")),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EEF5FB")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    story.extend([table, Spacer(1, 5)])

    sections = [
        (
            "项目简介",
            "MoonSpectrum 是一个面向 MoonBit 生态的科学信号处理基础库，提供复数运算、DFT/FFT、频谱分析、窗函数、卷积、基础 FIR 滤波和命令行分析工具。项目服务于传感器数据、实验数据、振动信号、周期信号、教学示例和边缘计算前处理。与音频 DSP/音频引擎不同，本项目不绑定播放、采集或具体设备后端，而是沉淀可复用、可验证、可扩展的通用算法层。",
        ),
        (
            "为什么值得做",
            "MoonBit 生态已有不少 Web、图形、Markdown、数据库和音频相关项目，但通用科学信号处理方向仍缺少小而稳定的基础包。FFT、窗函数、卷积和频谱分析是工程、物理实验、嵌入式传感器、振动诊断和教学场景中的共性能力，适合作为 MoonBit 跨学科应用生态的基础设施。",
        ),
        (
            "拟实现的核心功能",
            "1. 复数类型与近似比较；2. DFT、radix-2 FFT、inverse FFT；3. 幅度谱、功率谱、频率 bin、主频检测；4. 正弦波、方波、脉冲、chirp、确定性白噪声；5. Rectangular、Hann、Hamming、Blackman 窗函数；6. 线性卷积、循环卷积、移动平均、FIR 低通/高通 taps；7. CLI 支持 demo、fft、analyze、window、convolve，并用 CSV fixtures 做可复现示例。",
        ),
        (
            "实现计划与验收方式",
            "项目采用根包导出稳定 API，cmd/main 只作为 CLI 入口。仓库包含 README、LICENSE、CHANGELOG、CI、示例数据、接口文件 pkg.generated.mbti、验收脚本和一页 PDF。验收命令包括 moon info、moon fmt --check、moon check --warn-list +73、moon test、CLI smoke test，以及 scripts/verify_acceptance.ps1。",
        ),
        (
            "边界与扩展",
            "本期不做完整音频引擎、不做大型矩阵计算、不依赖 native FFI，优先保证算法清晰、测试充分、跨后端可运行。后续扩展方向包括 STFT/谱图、IIR 滤波、Welch PSD、重采样、更多 CSV/JSON 数据管线和 WebAssembly 可视化 Demo。",
        ),
    ]

    for title, body in sections:
        story.append(p(title, styles["section"]))
        story.append(p(body, styles["body"]))

    story.append(Spacer(1, 4))
    story.append(
        p(
            "提交口径：原创项目；公开仓库；计划保持 10-20 个有效 commits；GitHub 与 GitLink 同步；Mooncakes 发布前保留 dry-run/凭据状态说明。",
            styles["small"],
        )
    )

    doc.build(story)
    pages = len(PdfReader(str(OUT)).pages)
    if pages != 1:
        raise SystemExit(f"proposal must be one page, got {pages}")
    print(OUT)


if __name__ == "__main__":
    main()
